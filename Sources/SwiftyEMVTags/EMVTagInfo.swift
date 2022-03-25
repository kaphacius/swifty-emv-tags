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
        
        internal let tag: UInt64
        internal let name: String
        internal let description: String
        internal let source: Source
        internal let format: Format
        internal let kernel: Kernel
        internal let minLength: String
        internal let maxLength: String
        internal let byteMeaningList: [[String]]
        
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
                byteMeaningList: [[]]
            )
        }
    }
    
    internal static let defaultInfoSource = InfoSource()
    
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
