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
    
    /// Name of the kernel
    public let name: String
    
    /// Description of the kernel
    public let description: String
    
    /// Tag decoding information
    public let tags: [TagDecodingInfo]
    
    internal func decodeTag(_ bertlv: BERTLV) throws -> EMVTag.DecodedTag? {
        try tags.first(where: { $0.info.tag == bertlv.tag })
            .map {
                .init(
                    kernelName: name,
                    tagInfo: $0.info,
                    decodedBytes: try decodeBytes(bertlv.value, bytesInfo: $0.bytes)
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
