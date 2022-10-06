//
//  TagMappingTests.swift
//  
//
//  Created by Yurii Zadoianchuk on 04/10/2022.
//

import XCTest
@testable
import SwiftyEMVTags

final class TagMappingTests: XCTestCase {
    
    func testParsing() throws {
        let mockTagMappingData = try mockTagMappingData()
        let tagMappingInfoDict = try JSONSerialization.jsonObject(with: mockTagMappingData) as! JSONDictionary
        let sut = try JSONDecoder().decode(TagMapping.self, from: mockTagMappingData)
        let dictTagString: String = try tagMappingInfoDict.value(for: "tag")
        let dictTag = UInt64(dictTagString, radix: 16)
        let dictValues: [JSONDictionary] = try tagMappingInfoDict.value(for: "values")
        
        XCTAssertEqual(sut.tag, dictTag)
        XCTAssertEqual(sut.values.count, dictValues.count)
        
        try dictValues
            .compactMap { $0 as? [String: String] }
            .map { ($0["value"], $0["meaning"]) }
            .forEach { (value, meaning) in
                let value = try XCTUnwrap(value)
                let meaning = try XCTUnwrap(meaning)
                XCTAssertEqual(sut.values[value], meaning)
            }
    }
    
    func testDefaultMappings() throws {
        let defaultURLs = try TagMapping.defaultURLs()
        
        XCTAssertEqual(defaultURLs.count, TagMapping.defaultMappingCount)
        
        try defaultURLs.map { url in
            try Data(contentsOf: url)
        }.forEach { data in
            _ = try JSONDecoder().decode(TagMapping.self, from: data)
        }
    }
    
}
