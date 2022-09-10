//
//  TagDecodingInfoTests.swift
//  
//
//  Created by Yurii Zadoianchuk on 10/09/2022.
//

import XCTest
@testable
import SwiftyEMVTags

final class TagDecodingInfoTests: XCTestCase {

    func testParsing() throws {
        let url = URL(
            fileURLWithPath: Bundle.module.path(forResource: "tag_mock", ofType: "json")!
        )
        let data = try Data(contentsOf: url)
        let tagDecodingInfoDict = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>
        let tagDecodingInfo = try JSONDecoder().decode(TagDecodingInfo.self, from: data)
        
        XCTAssertEqual(tagDecodingInfo.bytes.count, try tagDecodingInfoDict.value(of: [Any].self, for: "bytes").count)
        
        let tagInfo = tagDecodingInfo.info
        let infoDict = try tagDecodingInfoDict.value(of: JSONDictionary.self, for: "info")
        
        try XCTAssertEqual(tagInfo.tag.hexString, infoDict.value(for: "tag"))
        try XCTAssertEqual(tagInfo.name, infoDict.value(for: "name"))
        try XCTAssertEqual(tagInfo.description, infoDict.value(for: "description"))
        try XCTAssertEqual(tagInfo.source.rawValue, infoDict.value(for: "source"))
        try XCTAssertEqual(tagInfo.format, infoDict.value(for: "format"))
        try XCTAssertEqual(tagInfo.kernel, infoDict.value(for: "kernel"))
        try XCTAssertEqual(tagInfo.minLength, infoDict.value(for: "minLength"))
        try XCTAssertEqual(tagInfo.maxLength, infoDict.value(for: "maxLength"))
    }

}
