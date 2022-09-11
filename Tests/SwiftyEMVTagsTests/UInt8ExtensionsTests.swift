//
//  UInt8ExtensionsTests.swift
//  
//
//  Created by Yurii Zadoianchuk on 10/09/2022.
//

import XCTest
@testable
import SwiftyEMVTags

final class UInt8ExtensionsTests: XCTestCase {

    func testBitExtraction() throws {
        try [
            ("00110000", "00100000", 2),
            ("11110000", "10100000", 10),
            ("11111110", "10000000", 64),
            ("00000001", "11111110", 0),
            ("00011100", "11110111", 5),
        ]
            .map {
                try (pattern: UInt8(pattern: $0.0),
                     byte: UInt8(pattern: $0.1),
                     expectedResult: UInt8($0.2))
            }
            .map { ($0.pattern, $0.byte.extractingBits(with: $0.pattern), $0.expectedResult) }
            .forEach { arg0 in
                let (pattern, sut, expectedResult) = arg0
                XCTAssertEqual(sut.patternWidth, pattern.nonzeroBitCount)
                XCTAssertEqual(sut.extracted, expectedResult)
            }
    }
    
    func testMatchesPattern() throws {
        let groupPattern: UInt8 = 0b11000000
        let bytes = [
            0b00000000,
            0b01000000,
            0b10000000,
            0b11000000
        ].map { (byte: UInt8) in
            byte.extractingBits(with: groupPattern)
        }.map(\.extracted)
        
        let valuePatterns: [UInt8] = [
            0b00000000,
            0b00000001,
            0b00000010,
            0b00000011
        ]
        
        XCTAssertTrue(
            zip(bytes, valuePatterns)
                .map { $0.0.matches(pattern: $0.1) }
                .allSatisfy { $0 }
        )
        
    }
    
    func testDoesntMatchPattern() throws {
        let groupPattern: UInt8 = 0b11000000
        let bytes = [
            0b00000000,
            0b01000000,
            0b10000000,
            0b11000000
        ].map { (byte: UInt8) in
            byte.extractingBits(with: groupPattern)
        }.map(\.extracted)
        
        let valuePatterns: [UInt8] = [
            0b00000001,
            0b00000000,
            0b00000011,
            0b00000001
        ]
        
        XCTAssertTrue(
            zip(bytes, valuePatterns)
                .map { $0.0.matches(pattern: $0.1) }
                .allSatisfy { $0 == false }
        )
        
    }

}
