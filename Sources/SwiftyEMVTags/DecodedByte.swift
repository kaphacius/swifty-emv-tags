//
//  DecodedByte.swift
//  
//
//  Created by Yurii Zadoianchuk on 08/09/2022.
//

import Foundation

extension EMVTag {
    
    /// Represents a decoded byte
    public struct DecodedByte {
        
        /// The name of the byte, if applicable
        public let name: String?
        
        /// The list of decoded groups
        public let groups: [Group]
        
    }
    
}

extension EMVTag.DecodedByte {
    
    /// Represents one decoded group within a byte
    public struct Group {
        
        /// Name of the group, if applicable
        public let name: String?
        
        /// Decoded meaning of the group
        public let meaning: String
        
        /// Lowest ``width`` bits represent the actual bit mapping
        public let pattern: UInt
        
        /// The bit width of the group
        public let width: UInt8
        
    }
    
}
