//
//  File.swift
//  
//
//  Created by Yurii Zadoianchuk on 10/09/2022.
//

import Foundation

extension FixedWidthInteger {
    
    public init<T>(
        from decoder: Decoder,
        radix: Int,
        codingKey: T
    ) throws where T: CodingKey {
        let stringValue = try decoder
            .container(keyedBy: T.self)
            .decode(String.self, forKey: codingKey)
        
        guard let value = Self.init(stringValue, radix: radix) else {
            throw DecodingError.dataCorrupted(
                .init(
                codingPath: [codingKey],
                debugDescription: "Unable to convert \(stringValue) to \(Self.self)"
                )
            )
        }
        
        self = value
    }
    
}
