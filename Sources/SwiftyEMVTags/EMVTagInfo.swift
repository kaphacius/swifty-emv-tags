//
//  File.swift
//  
//
//  Created by Yurii Zadoianchuk on 16/03/2022.
//

import Foundation

/// Represents information about an EMV tag
public struct Info: Decodable {
    
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
    
}

extension Info {
    
    public enum Source: String, Equatable, CustomStringConvertible, Codable {
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
