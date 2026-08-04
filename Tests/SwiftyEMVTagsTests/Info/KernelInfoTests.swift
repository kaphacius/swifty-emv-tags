//
//  KernelInfoTests.swift
//  
//
//  Created by Yurii Zadoianchuk on 10/09/2022.
//

import XCTest
@testable
import SwiftyEMVTags

final class KernelInfoTests: XCTestCase {

    func testParsing() throws {
        let data = try mockKernelInfoData
        let plainData = try JSONSerialization.jsonObject(with: data) as! JSONDictionary
        let kernelInfo = try JSONDecoder().decode(KernelInfo.self, from: data)

        XCTAssertEqual(kernelInfo.name, try plainData.value(for: "name"))
        XCTAssertEqual(kernelInfo.description, try plainData.value(for: "description"))
        XCTAssertEqual(kernelInfo.tags.count, try plainData.value(of: [Any].self, for: "tags").count)
    }

    func testParsingWithoutTriggerTagsDefaultsToEmpty() throws {
        // Old-format kernel JSON with no triggerTags/exclusiveWith should still decode.
        let kernelInfo = try JSONDecoder().decode(KernelInfo.self, from: try mockKernelInfoData)

        XCTAssertEqual(kernelInfo.triggerTags, [])
        XCTAssertEqual(kernelInfo.exclusiveWith, [])
    }

    func testParsingTriggerTagsAndExclusiveWith() throws {
        let kernelInfo = try JSONDecoder().decode(KernelInfo.self, from: try mockKernelInfoWithTriggersData)

        XCTAssertEqual(kernelInfo.triggerTags, [0x9F06, 0xDF01])
        XCTAssertEqual(kernelInfo.exclusiveWith, ["custom-visa-variant-2"])
    }
    
    func testDefaultInfo() throws {
        let defaultURLs = try KernelInfo.defaultURLs()
        
        XCTAssertEqual(defaultURLs.count, KernelInfo.defaultKernelInfoCount)
        
        try defaultURLs.map { url in
            try Data(contentsOf: url)
        }.forEach { data in
            _ = try JSONDecoder().decode(KernelInfo.self, from: data)
        }
    }

}
