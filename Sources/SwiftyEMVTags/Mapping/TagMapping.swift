//
//  TagMapping.swift
//  
//
//  Created by Yurii Zadoianchuk on 04/10/2022.
//

import Foundation

public struct TagMapping: Decodable {
    
    public struct Value: Decodable {
        
        public let value: String
        public let meaning: String
        
    }
    
    public let tag: UInt64
    public let kernel: String
    public let description: String
    public let values: Dictionary<String, String>
    
    enum CodingKeys: CodingKey {
        case tag
        case kernel
        case description
        case values
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tag = try .init(from: decoder, radix: 16, codingKey: CodingKeys.tag)
        self.kernel = try container.decode(String.self, forKey: .kernel)
        self.description = try container.decode(String.self, forKey: .description)
        let values = try container.decode([Value].self, forKey: .values)
        self.values = .init(
            uniqueKeysWithValues: values.map { ($0.value, $0.meaning) }
        )
    }
    
}

extension TagMapping {
    
    internal static let defaultMappingCount = 8
    
    internal static func defaultURLs() throws -> [URL] {
        try defaultJSONResources(.tagMapping)
    }
    
}

