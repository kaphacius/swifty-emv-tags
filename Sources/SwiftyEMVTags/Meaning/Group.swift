//
//  Group.swift
//  
//
//  Created by Yurii Zadoianchuk on 07/09/2022.
//

import Foundation

extension ByteInfo {
    
    /// Represents rules for decoding one group within a ``ByteInfo``
    public struct Group: Codable {
        
        /// Encoding rule
        public enum Kind: Codable {
            
            /// Group is mapped across multiple bits
            /// Actual mapping is described within ``ByteInfo/Group/Bitmap`` struct
            case bitmap(Bitmap)
            
            /// Group representes a Binary-Coded Decimal (BCD) value
            case bcd
            
            /// Group represens a hex value
            case hex
            
            /// Group represents a boolean value
            case bool
            
            /// Group is RFU
            case rfu
        }
        
        /// Describes mapping that spans across multiple bits
        public struct Bitmap: Codable {
            
            /// Describes mapping of an individual meaning within a group
            public struct Mapping: Codable {
                
                /// Lowest bits represent the actual value
                /// The number of lowest bits is ``ByteInfo/Group/pattern`` set bits
                public let pattern: UInt8
                
                /// Meaning of this specific mapping variant
                public let meaning: String
                
            }
            
            /// Describes possible mappings for this ``ByteInfo/Group``
            public let mappings: [Mapping]
            
        }
        
        /// Name of the group
        public let name: String
        
        /// Kind of mapping used to encode group meaning
        public let kind: Kind
        
        /// Describes which bits from the byte represent the group
        /// i.e. 00001100 means b4 and b3 represent this group
        public let pattern: UInt8
        
    }
    
}
