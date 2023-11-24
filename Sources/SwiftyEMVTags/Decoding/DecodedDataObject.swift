//
//  DecodedDataObject.swift
//
//
//  Created by Yurii Zadoianchuk on 23/11/2023.
//

import Foundation

public typealias DecodedDOL = [DecodedDataObject]

/// Represents a decoded single unit in Data Object List (DOL)
public struct DecodedDataObject: Equatable {
    
    /// Expected tag in DOL
    public let tag: UInt64
    
    /// Expected length of the tag in DOL
    public let expectedLength: Int
    
    /// Name of the expected tag
    public let name: String
    
}
