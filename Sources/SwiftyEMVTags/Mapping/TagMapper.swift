//
//  TagMapper.swift
//  
//
//  Created by Yurii Zadoianchuk on 04/10/2022.
//

import Foundation

public protocol AnyTagMapper {
    
    func extentedDescription(
        for tagInfo: TagInfo,
        value: [UInt8]
    ) -> String?
    
}

public final class TagMapper: AnyTagMapper {
    
    private (set) public var mappings: Dictionary<UInt64, TagMapping> = [:]
    private (set) public var mappedTags: [String] = []
    
    public static func defaultMapper() throws -> TagMapper {
        let decoder = JSONDecoder()
        let tagMappingList = try TagMapping.defaultURLs()
            .map { try Data(contentsOf: $0) }
            .map { try decoder.decode(TagMapping.self, from: $0) }
        return .init(mappings: tagMappingList)
    }
    
    internal init(mappings: [TagMapping]) {
        self.mappedTags = mappings.map(\.tag.hexString)
        self.mappings = .init(
            uniqueKeysWithValues: mappings.map { ($0.tag, $0) }
        )
    }
    
    public func addTagMapping(newMapping: TagMapping) throws {
        guard mappings.keys.contains(newMapping.tag) == false else {
            throw EMVTagError.tagMappingAlreadyExists(tag: newMapping.tag)
        }
        
        mappings[newMapping.tag] = newMapping
        mappedTags.append(newMapping.tag.hexString)
    }
    
    public func removeTagMapping(tag: UInt64) throws {
        guard let idx = mappedTags.firstIndex(of: tag.hexString) else {
            return
        }
        
        mappings.removeValue(forKey: tag)
        mappedTags.remove(at: idx)
    }
    
    public func extentedDescription(
        for tagInfo: TagInfo,
        value: [UInt8]
    ) -> String? {
        // If format starts with 'a' - it is ascii encoded string
        if tagInfo.format.hasPrefix("a") {
            return String(bytes: value, encoding: .ascii)
        } else if let mapping = mappings[tagInfo.tag] {
            return mapping.values[value.map(\.hexString).joined()]
        } else {
            return nil
        }
    }
    
}
