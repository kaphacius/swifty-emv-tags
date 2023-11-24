//
//  TagDecoderTests.swift
//  
//
//  Created by Yurii Zadoianchuk on 17/12/2022.
//

import XCTest
import SwiftyBERTLV
@testable import SwiftyEMVTags

final class TagDecoderTests: XCTestCase {

    func testDecoding() throws {
        let sut = TagDecoder(
            kernelInfoList: [.mockGeneralKernelInfo],
            tagMapper: try .defaultMapper()
        )
        
        let hexStringToDecode = "9F34032808C8"
        let parseResult = try BERTLV.parse(hexString: hexStringToDecode)
        XCTAssertEqual(parseResult.count, 1)
        let berTLV = try XCTUnwrap(parseResult.first)
        
        let result = sut.decodeBERTLV(berTLV)
        
        XCTAssertEqual(result.category, .plain)
        XCTAssertEqual(result.tag, berTLV)
        
        guard case let .singleKernel(decodedTag) = result.decodingResult else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(decodedTag.tagInfo.name, "Terminal Capabilities")
    }
    
    func testDecodingContextTag() throws {
        let sut = TagDecoder(
            kernelInfoList: [.mockGeneralKernelInfo],
            tagMapper: try .defaultMapper()
        )
        
        let hexStringToDecode = "E5069F34032808C8"
        let parseResult = try BERTLV.parse(hexString: hexStringToDecode)
        XCTAssertEqual(parseResult.count, 1)
        let berTLV = try XCTUnwrap(parseResult.first)
        
        let result = sut.decodeBERTLV(berTLV)
        
        guard case let .constructed(subtags) = result.category else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(result.tag, berTLV)
        
        let firstSubtag = try XCTUnwrap(subtags.first)
        
        guard case let .singleKernel(decodedSubtag) = firstSubtag.decodingResult else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(decodedSubtag.tagInfo.name, "E5 context tag")
    }
    
    func testDecodingNonContextTagInContext() throws {
        let sut = TagDecoder(
            kernelInfoList: [.mockGeneralKernelInfo],
            tagMapper: try .defaultMapper()
        )
        
        let hexStringToDecode = "E1069F33032808C8"
        let parseResult = try BERTLV.parse(hexString: hexStringToDecode)
        XCTAssertEqual(parseResult.count, 1)
        let berTLV = try XCTUnwrap(parseResult.first)
        
        let result = sut.decodeBERTLV(berTLV)
        
        guard case let .constructed(subtags) = result.category else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(result.tag, berTLV)
        
        let firstSubtag = try XCTUnwrap(subtags.first)
        
        guard case let .singleKernel(decodedSubtag) = firstSubtag.decodingResult else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(decodedSubtag.tagInfo.name, "Terminal Capabilities")
    }
    
    func testDecodingDOLTag() throws {
        let sut = TagDecoder(
            kernelInfoList: [.mockGeneralKernelInfo],
            tagMapper: try .defaultMapper()
        )
        
        let hexStringToDecode = "9F34069F33029F3806"
        let parseResult = try BERTLV.parse(hexString: hexStringToDecode)
        XCTAssertEqual(parseResult.count, 1)
        let berTLV = try XCTUnwrap(parseResult.first)
        let result = sut.decodeBERTLV(berTLV)
        
        guard case let .singleKernel(result) = result.decodingResult else {
            XCTFail()
            return
        }
        
        guard case let .dol(dol) = result.result else {
            XCTFail()
            return
        }
        
        let expectedDecodedDOL: DecodedDOL = [
            .init(tag: 0x9f33, expectedLength: 02, name: "Terminal Capabilities"),
            .init(tag: 0x9f38, expectedLength: 06, name: "Some tag")
        ]
        
        XCTAssertEqual(dol, expectedDecodedDOL)
    }

}
