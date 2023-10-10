//
//  DecodedByteTests.swift
//  
//
//  Created by Yurii Zadoianchuk on 11/09/2022.
//

import XCTest
@testable
import SwiftyEMVTags

final class DecodedByteTests: XCTestCase {

    func testByteDecoding() throws {
        let mockTagData = try mockTagData
        let tagDecodingInfo = try JSONDecoder().decode(TagDecodingInfo.self, from: mockTagData)
        
        let bytesInfo = tagDecodingInfo.bytes
        
        let mockBytes: [UInt8] = [
            0b10001001,
            0b01000000,
            0b10101000,
            0b00101100
        ]
        
        XCTAssertEqual(mockBytes.count, bytesInfo.count)
        
        try zip(mockBytes, bytesInfo)
            .map { try (EMVTag.DecodedByte(byte: $0.0, info: $0.1), $0.1) }
            .forEach { assertDecodedByte($0.0, byteInfo: $0.1) }
    }

    func assertDecodedByte(_ sut: EMVTag.DecodedByte, byteInfo: ByteInfo) {
        XCTAssertEqual(sut.name, byteInfo.name)
        XCTAssertEqual(sut.groups.count, byteInfo.groups.count)
        
        zip(sut.groups, byteInfo.groups)
            .forEach { assertDecodedGroup($0.0, infoGroup: $0.1) }
    }
    
    func assertDecodedGroup(
        _ sut: EMVTag.DecodedByte.Group,
        infoGroup: ByteInfo.Group
    ) {
        XCTAssertEqual(sut.name, infoGroup.name)
        XCTAssertEqual(sut.width, infoGroup.pattern.nonzeroBitCount)
        
        switch (sut.type, infoGroup.type) {
        case (.RFU, .RFU):
            XCTAssertEqual(sut.name, ByteInfo.Group.MappingType.RFU.stringValue)
        case (.bool(let isSet), .bool):
            XCTAssertTrue((sut.pattern == 1) == isSet)
        case (.hex(let hexValue), .hex):
            XCTAssertEqual(sut.pattern, hexValue)
        case (.bitmap(let mappingResult), .bitmap(let infoMappings)):
            if let matchIndex = infoMappings.firstIndex(where: { $0.pattern.matches(shiftedBits: sut.pattern) }) {
                XCTAssertEqual(mappingResult.matchIndex, matchIndex)
                zip(mappingResult.mappings, infoMappings)
                    .forEach { (decodedMapping, infoMapping) in
                        switch (decodedMapping.pattern, infoMapping.pattern) {
                        case (.concrete(let lhs), .concrete(let rhs)):
                            XCTAssertEqual(lhs, rhs)
                        case (.allOtherValues(let lhs), .allOtherValues):
                            XCTAssertEqual(lhs, sut.pattern)
                        default:
                            XCTFail("Mismatched mapping")
                        }
                        
                        XCTAssertEqual(decodedMapping.meaning, infoMapping.meaning)
                    }
            } else {
                XCTFail("Unable to match bitmap patterns")
            }
        default:
            XCTFail("Group types don't match")
        }
    }

}
