//
//  KernelInfo.swift
//  
//
//  Created by Yurii Zadoianchuk on 10/09/2022.
//

import Foundation
import SwiftyBERTLV

/// Represents information about kernel and associated tags
public struct KernelInfo: Decodable, Identifiable {
    
    /// Category of the kernel
    public enum Category: String, Decodable {
        /// Kernel describing scheme-specific tags
        case scheme
        
        /// Kernel describing vendor-specifig tags
        case vendor
    }
    
    /// The identifier of the kernel
    public let id: String
    
    /// Name of the kernel
    public let name: String
    
    /// Category of the kernel
    public let category: Category
    
    /// Description of the kernel
    public let description: String
    
    /// Tag decoding information
    public let tags: [TagDecodingInfo]
    
    public init(
        id: String,
        name: String,
        category: Category,
        description: String,
        tags: [TagDecodingInfo]
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.tags = tags
    }
    
    internal func decodeTag(
        _ bertlv: BERTLV,
        tagMapper: AnyTagMapper,
        context: UInt64? = nil
    ) -> EMVTag.DecodedTag? {
        matchingTag(for: bertlv.tag, context: context)
            .map { tagInfo in
                .init(
                    kernel: id,
                    tagInfo: tagInfo.info,
                    result: decodingResult(
                        info: tagInfo,
                        tlv: bertlv,
                        tagMapper: tagMapper,
                        context: context
                    )
                )
            }
    }
    
    internal func decodeDOL(
        _ dol: DOL
    ) -> DecodedDOL {
        dol.map { dataObject in
            let name = matchingTag(for: dataObject.tag, context: nil)
                .map(\.info.name) ?? "Unknown tag"
            return DecodedDataObject(
                tag: dataObject.tag,
                expectedLength: dataObject.length,
                name: name
            )
        }
    }
    
    private func decodingResult(
        info: TagDecodingInfo,
        tlv: BERTLV,
        tagMapper: AnyTagMapper,
        context: UInt64? = nil
    ) -> EMVTag.DecodedTag.DecodingResult {
        if let result = decodeBytes(tlv.value, bytesInfo: info.bytes) {
            return result
        } else if let extendedDescription = tagMapper.extentedDescription(
            for: info.info,
            value: tlv.value
        ) {
            return extendedDescription
        } else if info.info.isDOL {
            do {
                let dol = try DataObject.parse(bytes: tlv.value)
                return .dol(decodeDOL(dol))
            } catch {
                return .error("Failure parsing DOL")
            }
        } else {
            return .noDecodingInfo
        }
    }
    
    private func matchingTag(
        for tag: UInt64,
        context: UInt64?
    ) -> TagDecodingInfo? {
        // Try with context first if present.
        // If no tags found - try without context.
        context.flatMap { ctx in
            tags.first(where: { $0.isMatching(tag: tag, context: ctx) })
        } ?? tags.first(where: { $0.isMatching(tag: tag, context: nil) })
    }
    
    private func decodeBytes(_ bytes: [UInt8], bytesInfo: [ByteInfo]) -> EMVTag.DecodedTag.DecodingResult? {
        guard bytesInfo.isEmpty == false else {
            return nil
        }
        
        guard bytes.count == bytesInfo.count else {
            return .error("TLV byte count does not match the count defined in the kernel info")
        }
        
        do {
            let bytes = try zip(bytes, bytesInfo)
                .map(EMVTag.DecodedByte.init)
            return .bytes(bytes)
        } catch {
            return .error(String(describing: error))
        }
    }
    
}

/// Represents decoding information about a specific tag
public struct TagDecodingInfo: Decodable {
    
    /// General tag information
    public let info: TagInfo
    
    /// Rules for decoding tag value bytes
    public let bytes: [ByteInfo]
    
    public enum CodingKeys: CodingKey {
        case info
        case bytes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.info = try container.decode(TagInfo.self, forKey: .info)
        self.bytes = try container.decodeIfPresent([ByteInfo].self, forKey: .bytes) ?? []
    }
    
    func isMatching(tag: UInt64, context: UInt64?) -> Bool {
        self.info.tag == tag && self.info.context == context
    }
    
}
