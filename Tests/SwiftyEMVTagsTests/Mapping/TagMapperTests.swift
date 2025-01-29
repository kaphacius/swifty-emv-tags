//
//  TagMapperTests.swift
//  
//
//  Created by Yurii Zadoianchuk on 04/10/2022.
//

import XCTest
@testable
import SwiftyEMVTags
@testable
import SwiftyBERTLV

final class TagMapperTests: XCTestCase {
    
    func testThrowsOnAddExistingMapping() throws {
        let sut = try TagMapper.defaultMapper()
        let existingMappingURL = try XCTUnwrap(TagMapping.defaultURLs().first)
        let existingMappingData = try Data(contentsOf: existingMappingURL)
        let existingMapping = try JSONDecoder().decode(TagMapping.self, from: existingMappingData)
        XCTAssertThrowsError(try sut.addTagMapping(newMapping: existingMapping))
    }
    
    func testDecodesAsciiFormat() throws {
        let decoder = try TagDecoder.defaultDecoder()
        let parsed = try BERTLV.parse(
            bytes: [0x50, 0x0A, 0x4D, 0x43, 0x45, 0x4E, 0x47, 0x42, 0x52, 0x47, 0x42, 0x50]
        )
        let tlv = try XCTUnwrap(parsed.first)
        let sut = try TagMapper.defaultMapper()
        let emvtag = decoder.decodeBERTLV(tlv)
        guard case let .singleKernel(info) = emvtag.decodingResult else {
            XCTFail()
            return
        }
        let extendedDescription = sut.extentedDescription(for: info.tagInfo, value: tlv.value)
        guard case let .asciiValue(asciiValue) = extendedDescription else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(asciiValue, "MCENGBRGBP")
    }
    
    func testMapsTag() throws {
        let decoder = try TagDecoder.defaultDecoder()
        let parsed = try BERTLV.parse(
            bytes: [0x9F, 0x06, 0x07, 0xA0, 0x00, 0x00, 0x00, 0x04, 0x10, 0x10]
        )
        let tlv = try XCTUnwrap(parsed.first)
        let sut = try TagMapper.defaultMapper()
        let emvtag = decoder.decodeBERTLV(tlv)
        guard case let .singleKernel(info) = emvtag.decodingResult else {
            XCTFail()
            return
        }
        let extendedDescription = sut.extentedDescription(for: info.tagInfo, value: tlv.value)
        guard case let .mapping(stringValue) = extendedDescription else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(
            stringValue,
            "MasterCard Credit/Debit (Global), Mastercard International"
        )
    }
    
    func testMapsAsciiTag() throws {
        let decoder = try TagDecoder.defaultDecoder()
        let parsed = try BERTLV.parse(
            bytes: [0x8A, 0x02, 0x30, 0x30]
        )
        let tlv = try XCTUnwrap(parsed.first)
        let sut = try TagMapper.defaultMapper()
        let emvtag = decoder.decodeBERTLV(tlv)
        guard case let .singleKernel(info) = emvtag.decodingResult else {
            XCTFail()
            return
        }
        let extendedDescription = sut.extentedDescription(for: info.tagInfo, value: tlv.value)
        
        guard case let .mapping(asciiValue) = extendedDescription else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(asciiValue, "00: Approve - Transaction Approved")
    }
    
}
