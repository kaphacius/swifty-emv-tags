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
        let url = URL(
            fileURLWithPath: Bundle.module.path(forResource: "general_kernel_mock", ofType: "json")!
        )
        let data = try Data(contentsOf: url)
        let plainData = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>
        let kernelInfo = try JSONDecoder().decode(KernelInfo.self, from: data)
        
        XCTAssertEqual(kernelInfo.name, try plainData.value(for: "name"))
        XCTAssertEqual(kernelInfo.description, try plainData.value(for: "description"))
        XCTAssertEqual(kernelInfo.tags.count, try plainData.value(of: [Any].self, for: "tags").count)
    }

}
