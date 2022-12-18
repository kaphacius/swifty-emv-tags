//
//  ArrayExtensionTests.swift
//  
//
//  Created by Yurii Zadoianchuk on 25/09/2022.
//

import XCTest
@testable
import SwiftyEMVTags

final class ArrayExtensionTests: XCTestCase {
    
    private var sut: EMVTag.DecodingResult!
    
    func testUnknownResult() {
        let results: [EMVTag.DecodingResult] = [.unknown]
        
        sut = results.flattenDecodingResults(context: nil)
        
        XCTAssertEqual(sut, .unknown)
    }
    
    func testSingleResult() {
        let resultss: [[EMVTag.DecodingResult]] = [
            [.unknown],
            [.singleKernel(.mockResult)],
            [.singleKernel(.mockErrorResult)]
        ]
        
        let suts = resultss.map { $0.flattenDecodingResults(context: nil) }
        
        XCTAssertEqual(suts, resultss.compactMap(\.first))
        
    }
    
    func testAllUnknown() {
        let results: [EMVTag.DecodingResult] = [
            .unknown,
            .unknown,
            .unknown,
            .unknown
        ]
        
        let sut = results.flattenDecodingResults(context: nil)
        
        XCTAssertEqual(sut, .unknown)
    }
    
    func testAllErrors() {
        let results: [EMVTag.DecodingResult] = [
            .singleKernel(.mockErrorResult),
            .singleKernel(.mockErrorResult),
            .singleKernel(.mockErrorResult)
        ]
        
        let sut = results.flattenDecodingResults(context: nil)
        
        if case let EMVTag.DecodingResult.multipleKernels(decodedTags) = sut {
            XCTAssertEqual(decodedTags.count, results.count)
        } else {
            XCTFail()
        }
    }
    
    func testSingleToMultiple() {
        let mockDecodedTags: [EMVTag.DecodedTag] = [
            .mockResult,
            .mockErrorResult,
            .mockResult
        ]
        let results: [EMVTag.DecodingResult] = mockDecodedTags
            .map(EMVTag.DecodingResult.singleKernel)
        
        let sut = results.flattenDecodingResults(context: nil)
        
        if case let EMVTag.DecodingResult.multipleKernels(decodedTags) = sut {
            XCTAssertEqual(decodedTags, mockDecodedTags)
        } else {
            XCTFail()
        }
    }
    
    func testContextBound() {
        let mockDecodedContextBoundTag: EMVTag.DecodedTag = .mockContextBoundResult
        
        let mockDecodedTags: [EMVTag.DecodedTag] = [
            .mockResult,
            mockDecodedContextBoundTag
        ]
        let results: [EMVTag.DecodingResult] = mockDecodedTags
            .map(EMVTag.DecodingResult.singleKernel)
        
        let sut = results.flattenDecodingResults(context: 0xE1)
        
        if case let EMVTag.DecodingResult.singleKernel(decodedTag) = sut {
            XCTAssertEqual(decodedTag, mockDecodedContextBoundTag)
        } else {
            XCTFail()
        }
    }
    
    func testWrongContext() {
        let mockDecodedContextBoundTag: EMVTag.DecodedTag = .mockContextBoundResult
        
        let mockDecodedTags: [EMVTag.DecodedTag] = [
            .mockResult,
            mockDecodedContextBoundTag
        ]
        let results: [EMVTag.DecodingResult] = mockDecodedTags
            .map(EMVTag.DecodingResult.singleKernel)
        
        let sut = results.flattenDecodingResults(context: 0xE2)
        
        if case let EMVTag.DecodingResult.multipleKernels(decodedTags) = sut {
            XCTAssertEqual(decodedTags, mockDecodedTags)
        } else {
            XCTFail()
        }
    }
    
}
