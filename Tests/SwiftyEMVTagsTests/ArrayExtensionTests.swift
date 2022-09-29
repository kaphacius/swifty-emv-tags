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
        
        sut = results.flattenDecodingResults()
        
        XCTAssertEqual(sut, .unknown)
    }
    
    func testSingleResult() {
        let resultss: [[EMVTag.DecodingResult]] = [
            [.unknown],
            [.singleKernel(.mockResult)],
            [.error(EMVTagError.byteCountNotEqual)]
        ]
        
        let suts = resultss.map { $0.flattenDecodingResults() }
        
        XCTAssertEqual(suts, resultss.compactMap(\.first))
        
    }
    
    func testAllUnknown() {
        let results: [EMVTag.DecodingResult] = [
            .unknown,
            .unknown,
            .unknown,
            .unknown
        ]
        
        let sut = results.flattenDecodingResults()
        
        XCTAssertEqual(sut, .unknown)
    }
    
    func testAllErrors() {
        let results: [EMVTag.DecodingResult] = [
            .error(EMVTagError.byteCountNotEqual),
            .error(EMVTagError.byteCountNotEqual),
            .error(EMVTagError.byteCountNotEqual)
        ]
        
        let sut = results.flattenDecodingResults()
        
        XCTAssertEqual(sut, results.first!)
    }
    
    func testSingleToMultiple() {
        let mockDecodedTags: [EMVTag.DecodedTag] = [
            .mockResult,
            .mockResult,
            .mockResult
        ]
        let results: [EMVTag.DecodingResult] = mockDecodedTags
            .map(EMVTag.DecodingResult.singleKernel)
        
        let sut = results.flattenDecodingResults()
        
        if case let EMVTag.DecodingResult.multipleKernels(decodedTags) = sut {
            XCTAssertEqual(decodedTags, mockDecodedTags)
        } else {
            XCTFail()
        }
    }
    
}
