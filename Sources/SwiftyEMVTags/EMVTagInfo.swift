//
//  File.swift
//  
//
//  Created by Yurii Zadoianchuk on 16/03/2022.
//

import Foundation

public protocol AnyEMVTagInfoSource {
    
    func info(for tag: UInt64, kernel: EMVTag.Kernel) -> EMVTag.Info
    
}

extension EMVTag {
    
    public struct Info: Equatable {

        public let tag: UInt64
        public let name: String
        public let description: String
        public let source: Source
        public let format: String
        public let kernel: Kernel
        public let minLength: String
        public let maxLength: String
        public let byteMeaningList: [[String]]
        
        public init(
            tag: UInt64,
            name: String,
            description: String,
            source: Source,
            format: String,
            kernel: Kernel, minLength: String,
            maxLength: String,
            byteMeaningList: [[String]]
        ) {
            self.tag = tag
            self.name = name
            self.description = description
            self.source = source
            self.format = format
            self.kernel = kernel
            self.minLength = minLength
            self.maxLength = maxLength
            self.byteMeaningList = byteMeaningList
        }
        
        public static func unknown(tag: UInt64) -> Info {
            Info(
                tag: tag,
                name: "Unknown tag",
                description: "",
                source: .unknown,
                format: "",
                kernel: .general,
                minLength: "",
                maxLength: "",
                byteMeaningList: []
            )
        }
    }
    
}
