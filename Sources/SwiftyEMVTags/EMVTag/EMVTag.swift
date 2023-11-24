//
//  SwiftyEMVTags.swift
//
//
//  Created by Yurii Zadoianchuk on 16/03/2022.
//

import SwiftyBERTLV
import Foundation

/// Represents parsed and decoded BERTLV
public struct EMVTag: Identifiable, Equatable {

    /// Used
    public typealias ID = UUID
    
    /// Identifier of the this instance
    public let id: ID
    
    /// BERTLV representation of the tag
    public let tag: BERTLV
    
    /// Tag category
    public let category: Category
    
    /// Tag decoding result
    public let decodingResult: DecodingResult
    
    /// Initializes the tag structure
    /// - Parameters:
    ///   - bertlv: BERTLV representation
    ///   - decodingResult: tag decoding result
    ///   - subtags: subtags if the tag is constructed
    public init(
        bertlv: BERTLV,
        decodingResult: DecodingResult,
        subtags: [DecodedSubtag]
    ) {
        self.tag = bertlv
        self.decodingResult = decodingResult
        
        switch bertlv.category {
        case .plain:
            self.category = .plain
        case .constructed(let bertlvSubtags):
            self.category = .constructed(
                subtags: Self.constructSubtags(
                    bertlvSubtags,
                    decodedSubtags: subtags
                )
            )
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
    
    /// Creates a tag instance for an uknown tag
    /// - Parameter bertlv: BERTLV
    /// - Returns: an instance of an unknown tag
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
