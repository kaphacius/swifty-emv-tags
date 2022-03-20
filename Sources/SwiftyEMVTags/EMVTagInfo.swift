//
//  File.swift
//  
//
//  Created by Yurii Zadoianchuk on 16/03/2022.
//

import Foundation

public protocol AnyEMVTagInfoSource {
    
    func info(for tag: UInt64, scheme: EMVTag.Scheme) -> EMVTag.Info
    
}

extension EMVTag {
    
    public struct Info: Equatable {
        
        internal let tag: UInt64
        internal let name: String
        internal let description: String
        internal let source: Source
        internal let format: Format
        internal let scheme: Scheme
        internal let minLength: String
        internal let maxLength: String
        internal let byteMeaningList: [[String]]
        
        internal static func unknown(tag: UInt64, scheme: Scheme) -> Info {
            Info(
                tag: tag,
                name: "Unknown tag",
                description: "Unknown description",
                source: .unknown,
                format: .unknown,
                scheme: scheme,
                minLength: "",
                maxLength: "",
                byteMeaningList: [[]]
            )
        }
        
        internal static func info(
            for tag: UInt64,
            scheme: Scheme,
            infoSource: AnyEMVTagInfoSource = defaultInfoSource
        ) -> Info {
            infoSource.info(for: tag, scheme: scheme)
        }
        
    }
    
    fileprivate static let defaultInfoSource = EMVTagInfoSource()
    
    fileprivate struct EMVTagInfoSource: AnyEMVTagInfoSource {
        
        private let infoSource: [EMVTag.Info] = []
        
        private struct Locator: Hashable {
            let tag: UInt64
            let scheme: Scheme
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(tag)
                hasher.combine(scheme)
            }
        }
        
        func info(for tag: UInt64, scheme: EMVTag.Scheme) -> EMVTag.Info {
            infoSource.first(
                where: { $0.tag == tag && $0.scheme.contains(scheme) }
            ) ?? .unknown(tag: tag, scheme: scheme)
        }
        
    }
    
}
