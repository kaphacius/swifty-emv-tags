//
//  KernelInfo.swift
//  
//
//  Created by Yurii Zadoianchuk on 10/09/2022.
//

import Foundation

/// Represents information about kernel and associated tags
public struct KernelInfo: Decodable {
    
    /// Name of the kernel
    public let name: String
    
    /// Description of the kernel
    public let description: String
    
    public let tags: [TagDecodingInfo]
    
}

/// Represents decoding information about a specific tag
public struct TagDecodingInfo: Decodable {
    
    /// General tag information
    public let info: Info
    
    /// Rules for decoding tag value bytes
    public let bytes: [ByteInfo]
    
}
