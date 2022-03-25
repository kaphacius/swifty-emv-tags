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
        public let format: Format
        public let kernel: Kernel
        public let minLength: String
        public let maxLength: String
        public let byteMeaningList: [[String]]
        
        public static func unknown(tag: UInt64) -> Info {
            Info(
                tag: tag,
                name: "Unknown tag",
                description: "",
                source: .unknown,
                format: .unknown,
                kernel: .all,
                minLength: "",
                maxLength: "",
                byteMeaningList: []
            )
        }
    }
    
    public static let defaultInfoSource: AnyEMVTagInfoSource = InfoSource()
    
    internal struct InfoSource: AnyEMVTagInfoSource {
        
        private let infoSource: [EMVTag.Info] = []
        
        private struct Locator: Hashable {
            let tag: UInt64
            let kernel: Kernel
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(tag)
                hasher.combine(kernel)
            }
        }
        
        func info(for tag: UInt64, kernel: Kernel) -> EMVTag.Info {
            infoSource.first(
                where: { $0.tag == tag && $0.kernel.contains(kernel) }
            ) ?? .unknown(tag: tag)
        }
        
    }
    
}
