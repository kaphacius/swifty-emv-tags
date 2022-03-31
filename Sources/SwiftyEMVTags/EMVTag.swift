//
//  SwiftyEMVTags.swift
//
//
//  Created by Yurii Zadoianchuk on 16/03/2022.
//

import SwiftyBERTLV
import Foundation

public struct EMVTag: Equatable, Identifiable {
    
    public let id = UUID()
    
    public let tag: UInt64
    public let name: String
    public let description: String
    public let source: Source
    public let format: Format
    public let kernel: Kernel
    
    public let isConstructed: Bool
    public let value: [UInt8]
    public let subtags: [EMVTag]
    
    public let decodedMeaningList: [DecodedByte]
    
    public init(
        tlv: BERTLV,
        kernel: Kernel = .all,
        infoSource: AnyEMVTagInfoSource = defaultInfoSource
    ) {
        
        let info: Info = infoSource.info(for: tlv.tag, kernel: kernel)
        let subtags: [EMVTag]
        
        if tlv.isConstructed {
            subtags = tlv.subTags.map { .init(tlv: $0, kernel: kernel, infoSource: infoSource) }
        } else {
            subtags = []
        }
        
        self.init(tlv: tlv, info: info, subtags: subtags)
    }
    
    public init(tlv: BERTLV, info: EMVTag.Info, subtags: [EMVTag]) {
        self.tag = tlv.tag
        self.name = info.name
        self.description = info.description
        self.source = info.source
        self.format = info.format
        self.kernel = info.kernel
        
        self.isConstructed = tlv.isConstructed
        self.value = tlv.value
        
        self.subtags = subtags
        
        self.decodedMeaningList = zip(value, info.byteMeaningList)
            .map { (byte, byteMeaningList) in
                zip((0..<byte.bitWidth).reversed(), byteMeaningList)
                    .map { BitMeaning(meaning: $1, byte: byte, bitIdx: $0) }
            }.map(DecodedByte.init(bitList:))
    }
    
}

extension EMVTag {
    
    public enum Source: String, Equatable, CustomStringConvertible, Codable {
        case unknown
        case kernel
        case terminal
        case card
        case config
        case issuer
        
        public var description: String {
            rawValue.capitalized
        }
    }
    
    public enum Format: String, Equatable, CustomStringConvertible, Codable {
        case unknown
        case binary
        case BCD
        case date
        
        public var description: String {
            rawValue.capitalized
        }
    }
    
    public struct Kernel: Equatable, OptionSet, Hashable, CaseIterable, CustomStringConvertible, Codable {
        
        public static let allCases: [EMVTag.Kernel] = [
            .kernel1, .kernel2, .kernel3, .kernel4, .kernel5, .kernel6, .kernel7
        ]
        
        public static let kernel1 = Kernel(rawValue: 1 << 0)
        public static let kernel2 = Kernel(rawValue: 1 << 1)
        public static let kernel3 = Kernel(rawValue: 1 << 2)
        public static let kernel4 = Kernel(rawValue: 1 << 3)
        public static let kernel5 = Kernel(rawValue: 1 << 4)
        public static let kernel6 = Kernel(rawValue: 1 << 5)
        public static let kernel7 = Kernel(rawValue: 1 << 5)
        public static let all = Kernel(
            rawValue: Self.allCases
                .map(\.rawValue)
                .reduce(0, |)
        )
        
        public let rawValue: UInt64
        
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }
        
        public var description: String {
            if self == .all {
                return "All"
            }
            
            let kernelNumber = self.rawValue.bitWidth - self.rawValue.leadingZeroBitCount
            
            return "\(kernelNumber)"
        }
        
    }
    
    public struct BitMeaning: Equatable {
        
        public let meaning: String
        public let isSet: Bool
        
        internal init(meaning: String, byte: UInt8, bitIdx: Int) {
            self.meaning = meaning
            self.isSet = ((byte >> bitIdx) & 0x01) == 0x01
        }
        
    }
    
    public struct DecodedByte: Equatable {
        
        public let bitList: [BitMeaning]
        
    }
    
}
