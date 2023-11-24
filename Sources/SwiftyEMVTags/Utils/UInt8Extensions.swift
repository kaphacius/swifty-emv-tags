//
//  File.swift
//  
//
//  Created by Yurii Zadoianchuk on 10/09/2022.
//

import Foundation

internal struct BitExtractionResult {
    
    let extracted: UInt8
    let patternWidth: Int
    
}

extension UInt8 {
    
    init(pattern: String) throws {
        guard let decoded = UInt8(pattern, radix: 2) else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: [],
                    debugDescription: "Unable to create UInt8 with pattern \(pattern)"
                )
            )
        }
        
        self = decoded
    }
    
    func extractingBits(with pattern: UInt8) -> BitExtractionResult {
        let shift = pattern.bitWidth - pattern.leadingZeroBitCount - pattern.nonzeroBitCount
        return .init(
            extracted: (self & pattern) >> shift,
            patternWidth: pattern.nonzeroBitCount
        )
    }
    
    func matches(pattern: UInt8) -> Bool {
        self == pattern
    }
    
    var bitString: String {
        String(repeating: "0", count: self.leadingZeroBitCount) + String(self, radix: 2)
    }
    
    var binaryCodedDecimal: UInt8 {
        (self >> 4) * 10 + (self & 0b00001111)
    }
    
}
