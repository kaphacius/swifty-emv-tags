//
//  Info.swift
//  
//
//  Created by Yurii Zadoianchuk on 16/03/2022.
//

import Foundation

/// Represents information about an EMV tag
public struct Info: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case tag
        case name
        case description
        case source
        case format
        case kernel
        case minLength
        case maxLength
    }
    
    /// Tag value
    public let tag: UInt64
    
    /// Name of the tag
    public let name: String
    
    /// Description of the tag
    public let description: String
    
    /// Source of the tag
    public let source: Source
    
    /// Format of the tag
    public let format: String
    
    /// Kernel that describes the tag
    /// This value contains `general` in case the tag is common for all kernels
    public let kernel: String
    
    /// Minimal length of the tag value
    public let minLength: String
    
    /// Maximum length of the tag value
    public let maxLength: String
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.tag = try .init(from: decoder, radix: 16, codingKey: CodingKeys.tag)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.source = try container.decode(Source.self, forKey: .source)
        self.format = try container.decode(String.self, forKey: .format)
        self.kernel = try container.decode(String.self, forKey: .kernel)
        self.minLength = try container.decode(String.self, forKey: .minLength)
        self.maxLength = try container.decode(String.self, forKey: .maxLength)
    }
    
}

extension Info {
    
    public enum Source: String, Equatable, CustomStringConvertible, Decodable {
        case unknown
        case kernel
        case terminal
        case card
        case config
        case issuer
        
        public var description: String {
            rawValue.capitalized
        }
    }
    
}
