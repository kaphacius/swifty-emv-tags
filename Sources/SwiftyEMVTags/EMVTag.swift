//
//  SwiftyEMVTags.swift
//
//
//  Created by Yurii Zadoianchuk on 16/03/2022.
//

import SwiftyBERTLV
import Foundation

public struct EMVTag: Identifiable, Equatable {

    public typealias ID = UUID
    
    public let id: ID
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
        
        self.id = .init()
    }
    
    public init(
        id: ID,
        tag: BERTLV,
        category: Category,
        decodingResult: DecodingResult
    ) {
        self.id = id
        self.tag = tag
        self.category = category
        self.decodingResult = decodingResult
    }
    
    public static func unknownTag(bertlv: BERTLV) -> EMVTag {
        .init(
            id: .init(),
            tag: bertlv,
            category: .plain,
            decodingResult: .unknown
        )
    }
    
    internal func updatingDecodingResult(
        with newTag: EMVTag
    ) -> EMVTag {
        .init(
            id: self.id,
            tag: self.tag,
            category: category.updatingDecodingResults(with: newTag.category),
            decodingResult: newTag.decodingResult
        )
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
