//
//  EMVTagExtensions.swift
//  
//
//  Created by Yurii Zadoianchuk on 08/10/2022.
//

import Foundation
import SwiftyBERTLV

extension EMVTag {
    
    public enum Category {
        
        /// Plan tag with value
        case plain
        
        /// Constructed tag, containing a TLV list of subtags
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
        
        public enum DecodingResult: Equatable {
            /// Tag can be decoded byte by byte
            case bytes([DecodedByte])
            
            /// Tag has mappings for specific values
            case mapping(String)
            
            /// Tag value is an ascii string
            case asciiValue(String)
            
            /// Tag value is a Data Object List
            case dol(DecodedDOL)
            
            /// Error decoding tag
            case error(String)
            
            /// Tag has no decoding info
            case noDecodingInfo
        }
        
        public let kernel: String
        public let tagInfo: TagInfo
        public let result: DecodingResult
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
        case (.plain, .constructed), (.constructed, .plain):
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
        case let (.bytes(llhs), .bytes(rrhs)):
            return llhs == rrhs
        case let (.mapping(llhs), .mapping(rrhs)):
            return llhs == rrhs
        case let (.asciiValue(llhs), .asciiValue(rrhs)):
            return llhs == rrhs
        case let (.dol(llhs), .dol(rrhs)):
            return llhs == rrhs
        case let (.error(llhs), .error(rrhs)):
            return llhs == rrhs
        case (.noDecodingInfo, .noDecodingInfo):
            return true
        case (_, _):
            return false
        }
    }
    
}
