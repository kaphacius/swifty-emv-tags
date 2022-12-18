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
        
        internal func updatingDecodingResults(
            with newCategory: Category
        ) -> Category {
            switch (self, newCategory) {
            case (.plain, .plain):
                return .plain
            case let (.constructed(subtags), .constructed(newSubtags)):
                return .constructed(
                    subtags: zip(subtags, newSubtags)
                        .map { $0.0.updatingDecodingResult(with: $0.1) }
                )
            case (_, _):
                // This should not happen
                // TODO: What to do here?
                return self
            }
        }
    }
    
    public enum DecodingResult {
        case unknown
        case singleKernel(DecodedTag)
        case multipleKernels([DecodedTag])
    }
    
    public struct DecodedTag {
        public let kernel: String
        public let tagInfo: TagInfo
        public let result: Result<[DecodedByte], Error>
        public let extendedDescription: String?
    }
    
    public struct DecodedSubtag {
        public let result: DecodingResult
        public let subtags: [DecodedSubtag]
    }
    
}

extension EMVTag.Category: Equatable {
    
    static public func == (lhs: Self, rhs: Self) -> Bool {
        switch(lhs, rhs) {
        case (.plain, .plain):
            return true
        case (.constructed(let llhs), .constructed(let rrhs)):
            return llhs == rrhs
        default:
            return false
        }
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
        guard lhs.kernel == rhs.kernel && lhs.tagInfo == rhs.tagInfo else {
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
