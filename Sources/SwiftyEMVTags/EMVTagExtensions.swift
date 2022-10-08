//
//  EMVTagExtensions.swift
//  
//
//  Created by Yurii Zadoianchuk on 08/10/2022.
//

import Foundation

extension EMVTag {
    
    public enum Category {
        case plain
        case constructed(subtags: [EMVTag])
    }
    
    public enum DecodingResult {
        case unknown
        case singleKernel(DecodedTag)
        case multipleKernels([DecodedTag])
    }
    
    public struct DecodedTag {
        public let kernelName: String
        public let tagInfo: TagInfo
        public let result: Result<[DecodedByte], Error>
        public let extendedDescription: String?
    }
    
    public struct DecodedSubtag {
        public let result: DecodingResult
        public let subtags: [DecodedSubtag]
    }
    
}

extension EMVTag.DecodingResult: Equatable {
    
    static public func == (lhs: Self, rhs: Self) -> Bool {
        switch(lhs, rhs) {
        case (.unknown, .unknown):
            return true
        case (.singleKernel(let llhs), .singleKernel(let rrhs)):
            return llhs == rrhs
        case (.multipleKernels(let llhs), .multipleKernels(let rrhs)):
            return llhs == rrhs
        default:
            return false
        }
    }
    
}

extension EMVTag.DecodedTag: Equatable {
    
    static public func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.kernelName == rhs.kernelName && lhs.tagInfo == rhs.tagInfo else {
            return false
        }
        
        switch (lhs.result, rhs.result) {
        case (.success(let llhs), .success(let rrhs)):
            return llhs == rrhs
        case (.failure(let llhs), .failure(let rrhs)):
            return areEqual(llhs, rrhs)
        default:
            return false
        }
    }
    
}
