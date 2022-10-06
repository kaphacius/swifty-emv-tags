//
//  ByteInfoTests.swift
//  
//
//  Created by Yurii Zadoianchuk on 10/09/2022.
//

import XCTest
@testable
import SwiftyEMVTags

final class ByteInfoTests: XCTestCase {

    func testParsing() throws {
        let mockTagData = try mockTagData()
        let tagDecodingInfoDict = try JSONSerialization.jsonObject(with: mockTagData) as! JSONDictionary
        let tagDecodingInfo = try JSONDecoder().decode(TagDecodingInfo.self, from: mockTagData)
        
        let bytesInfo = tagDecodingInfo.bytes
        let bytesDict: [JSONDictionary] = try tagDecodingInfoDict.value(for: "bytes")
        
        try zip(bytesInfo, bytesDict).forEach {
            try assertByte($0.0, dict: $0.1)
        }
    }
    
    func assertByte(_ byte: ByteInfo, dict: JSONDictionary) throws {
        if let name = byte.name {
            try XCTAssertEqual(name, dict.value(for: "name"))
        } else {
            XCTAssertNil(dict["name"])
        }
        
        let groupsDict: [JSONDictionary] = try dict.value(for: "groups")
        
        try zip(byte.groups, groupsDict).forEach {
            try assertGroup($0.0, dict: $0.1)
        }
    }
    
    func assertGroup(_ group: ByteInfo.Group, dict: JSONDictionary) throws {
        try XCTAssertEqual(
            group.pattern, UInt8(dict.value(of: String.self, for: "pattern"), radix: 2)!
        )
        
        try XCTAssertEqual(group.type.stringValue, dict.value(for: "type"))
        
        switch group.type {
        case .RFU:
            XCTAssertNil(dict["name"])
        case .bitmap(let mappings):
            try zip(mappings, dict.value(of: [JSONDictionary].self, for: "mappings")).forEach {
                try assertMapping($0.0, dict: $0.1)
            }
        case .hex, .bool:
            break
        }
    }
    
    func assertMapping(_ mapping: ByteInfo.Group.Mapping, dict: JSONDictionary) throws {
        try XCTAssertEqual(mapping.meaning, dict.value(for: "meaning"))
        try XCTAssertEqual(
            mapping.pattern,
            UInt8(dict.value(of: String.self, for: "pattern"), radix: 2)!
        )
    }

}
