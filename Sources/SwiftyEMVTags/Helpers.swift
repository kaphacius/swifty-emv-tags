//
//  File.swift
//  
//
//  Created by Yurii Zadoianchuk on 10/09/2022.
//

import Foundation

extension FixedWidthInteger {
    
    public init<T>(
        from decoder: Decoder,
        radix: Int,
        codingKey: T
    ) throws where T: CodingKey {
        let stringValue = try decoder
            .container(keyedBy: T.self)
            .decode(String.self, forKey: codingKey)
        
        guard let value = Self.init(stringValue, radix: radix) else {
            throw DecodingError.dataCorrupted(
                .init(
                codingPath: [codingKey],
                debugDescription: "Unable to convert \(stringValue) to \(Self.self)"
                )
            )
        }
        
        self = value
    }
    
}

internal func areEqual<T: Swift.Error>(_ lhs: T, _ rhs: T) -> Bool {
    // Swifty check
    guard String(describing: lhs) == String(describing: rhs) else {
        return false
    }
    
    // Sanity check
    let nsl = lhs as NSError
    let nsr = rhs as NSError
    return nsl.isEqual(nsr)
}

func defaultJSONResources(with prefix: String) throws -> [URL] {
    guard let urls = Bundle.module.urls(
        forResourcesWithExtension: "json",
        subdirectory: nil
    ) else {
        throw EMVTagError.unableToLoadResources(prefix: prefix)
    }
    
    return urls.filter { $0.lastPathComponent.hasPrefix(prefix) }
}
