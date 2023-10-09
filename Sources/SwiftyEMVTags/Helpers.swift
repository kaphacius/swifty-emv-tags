//
//  File.swift
//  
//
//  Created by Yurii Zadoianchuk on 10/09/2022.
//

import Foundation

extension KeyedDecodingContainer {
    
    func decodeIntegerFromString<T: FixedWidthInteger>(
        radix: Int,
        forKey codingKey: K
    ) throws -> T {
        let stringValue = try self.decode(String.self, forKey: codingKey)
        
        guard let value = T(stringValue, radix: radix) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [codingKey],
                    debugDescription: "Unable to convert \(stringValue) to \(Self.self)"
                )
            )
        }
        
        return value
    }
    
    func decodeIntegerFromStringIfPresent<T: FixedWidthInteger>(
        radix: Int, forKey codingKey: K
    ) throws -> T? {
        guard let stringValue = try self.decodeIfPresent(String.self, forKey: codingKey) else {
            return nil
        }
        
        guard let value = T(stringValue, radix: radix) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [codingKey],
                    debugDescription: "Unable to convert \(stringValue) to \(Self.self)"
                )
            )
        }
        
        return value
    }
    
}

extension SingleValueDecodingContainer {
    
    func decodeIntegerFromString<T: FixedWidthInteger>(
        radix: Int
    ) throws -> T {
        let stringValue = try self.decode(String.self)
        
        guard let value = T(stringValue, radix: radix) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "Unable to convert \(stringValue) to \(Self.self)"
                )
            )
        }
        
        return value
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

enum Resource: String {
    case kernelInfo
    case tagMapping
    
    var prefix: String {
        switch self {
        case .kernelInfo:
            return "ki_"
        case .tagMapping:
            return "tm_"
        }
    }
}

func defaultJSONResources(_ resource: Resource) throws -> [URL] {
    guard let urls = Bundle.module.urls(
        forResourcesWithExtension: "json",
        subdirectory: nil
    ) else {
        throw EMVTagError.unableToLoadResources(resource.rawValue)
    }
    
    return urls.filter { $0.lastPathComponent.hasPrefix(resource.prefix) }
}
