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
    public let values: Dictionary<String, String>
    
    enum CodingKeys: CodingKey {
        case tag
        case values
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tag = try .init(from: decoder, radix: 16, codingKey: CodingKeys.tag)
        let values = try container.decode([Value].self, forKey: .values)
        self.values = .init(
            uniqueKeysWithValues: values.map { ($0.value, $0.meaning) }
        )
    }
    
}

extension TagMapping {
    
    internal static let defaultMappingCount = 7
    
    internal static func defaultURLs() throws -> [URL] {
        try defaultJSONResources(with: "tm_")
    }
    
}
