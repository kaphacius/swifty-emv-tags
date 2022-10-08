//
//  SwiftyEMVTags.swift
//
//
//  Created by Yurii Zadoianchuk on 16/03/2022.
//

import SwiftyBERTLV
import Foundation

public struct EMVTag: Identifiable {
    
    public typealias ID = UUID
    
    public let id: ID
    public let tag: BERTLV
    public let category: Category
    public let decodingResult: DecodingResult
    
    public init(
        bertlv: BERTLV,
        decodingResult: DecodingResult,
        subtags: [DecodedSubtag],
        id: ID = .init()
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
        
        self.id = id
    }
    
    public init(
        bertlv: BERTLV,
        decodingResult: DecodingResult,
        id: ID = .init()
    ) {
        self.tag = bertlv
        self.decodingResult = decodingResult
        self.category = .plain
        self.id = id
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
