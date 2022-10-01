//
//  KernelInfo.swift
//  
//
//  Created by Yurii Zadoianchuk on 10/09/2022.
//

import Foundation
import SwiftyBERTLV

/// Represents information about kernel and associated tags
public struct KernelInfo: Decodable {
    
    /// Category of the kernel
    public enum Category: String, Decodable {
        /// Kernel describing scheme-specific tags
        case scheme
        
        /// Kernel describing vendor-specifig tags
        case vendor
    }
    
    /// Name of the kernel
    public let name: String
    
    /// Category of the kernel
    public let category: Category
    
    /// Description of the kernel
    public let description: String
    
    /// Tag decoding information
    public let tags: [TagDecodingInfo]
    
    internal func decodeTag(_ bertlv: BERTLV) -> EMVTag.DecodedTag? {
        tags.first(where: { $0.info.tag == bertlv.tag })
            .map { tagInfo in
                .init(
                    kernelName: name,
                    tagInfo: tagInfo.info,
                    result: .init(
                        catching: { try decodeBytes(bertlv.value, bytesInfo: tagInfo.bytes) }
                    )
                )
            }
    }
    
    private func decodeBytes(_ bytes: [UInt8], bytesInfo: [ByteInfo]) throws -> [EMVTag.DecodedByte] {
        guard bytes.count == bytesInfo.count else {
            throw EMVTagError.byteCountNotEqual
        }
        
        return try zip(bytes, bytesInfo)
            .map(EMVTag.DecodedByte.init)
    }
    
}

/// Represents decoding information about a specific tag
public struct TagDecodingInfo: Decodable {
    
    /// General tag information
    public let info: TagInfo
    
    /// Rules for decoding tag value bytes
    public let bytes: [ByteInfo]
    
}
