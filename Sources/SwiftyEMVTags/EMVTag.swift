//
//  SwiftyEMVTags.swift
//
//
//  Created by Yurii Zadoianchuk on 16/03/2022.
//

import SwiftyBERTLV
import Foundation

public struct EMVTag {
    
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
    }
    
    public struct DecodedSubtag {
        public let result: DecodingResult
        public let subtags: [DecodedSubtag]
    }
    
    public let tag: BERTLV
    public let category: Category
    public let decodingResult: DecodingResult
    
    public init(
        bertlv: BERTLV,
        decodingResult: DecodingResult,
        subtags: [DecodedSubtag]
    ) {
        self.tag = bertlv
        self.decodingResult = decodingResult
        
        if bertlv.isConstructed {
            self.category = .constructed(
                subtags: Self.constructSubtags(
                    bertlv.subTags,
                    decodedSubtags: subtags
                )
            )
        } else {
            self.category = .plain
        }
    }
    
    public init(
        bertlv: BERTLV,
        decodingResult: DecodingResult
    ) {
        self.tag = bertlv
        self.decodingResult = decodingResult
        self.category = .plain
    }
    
    public static func unknownTag(bertlv: BERTLV) -> EMVTag {
        .init(bertlv: bertlv, decodingResult: .unknown)
    }
    
    private static func constructSubtags(
        _ tlvSubtags: [BERTLV],
        decodedSubtags: [DecodedSubtag]
    ) -> [EMVTag] {
        zip(tlvSubtags, decodedSubtags)
            .map { (tlvSubtag, decodedSubtag) in
                    .init(
                        bertlv: tlvSubtag,
                        decodingResult: decodedSubtag.result,
                        subtags: decodedSubtag.subtags
                    )
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
