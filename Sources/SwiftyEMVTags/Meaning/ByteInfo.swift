//
//  ByteInfo.swift
//  
//
//  Created by Yurii Zadoianchuk on 10/09/2022.
//

import Foundation
    
/// Describes decoding rules for one byte.
public struct ByteInfo: Decodable {
    
    /// Byte meaning, if applicable
    public let name: String?
    
    /// Groups representing meanings of specific byte ranges
    public let groups: [Group]
    
}
    
