//
//  SwiftyEMVTags.swift
//
//
//  Created by Yurii Zadoianchuk on 16/03/2022.
//

import SwiftyBERTLV
import Foundation

public struct EMVTag: Equatable, Identifiable {
    
    public let id: UUID
    
    public let tag: UInt64
    public let name: String
    public let description: String
    public let source: Source
    public let format: String
    public let kernel: Kernel
    
    public let isConstructed: Bool
    public let value: [UInt8]
    public let subtags: [EMVTag]
    
    public let decodedMeaningList: [DecodedByte]
    
    public init(
        tlv: BERTLV,
        kernel: Kernel = .general,
        infoSource: AnyEMVTagInfoSource
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
        self.id = UUID()
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
    
    public init(
        id: UUID,
        tag: UInt64,
        name: String,
        description: String,
        source: EMVTag.Source,
        format: String,
        kernel: EMVTag.Kernel,
        isConstructed: Bool,
        value: [UInt8],
        subtags: [EMVTag],
        decodedMeaningList: [EMVTag.DecodedByte]
    ) {
        self.id = id
        self.tag = tag
        self.name = name
        self.description = description
        self.source = source
        self.format = format
        self.kernel = kernel
        self.isConstructed = isConstructed
        self.value = value
        self.subtags = subtags
        self.decodedMeaningList = decodedMeaningList
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
    
    public enum Kernel: String, Equatable, Codable, CustomStringConvertible {
        case general
        case kernel1
        case kernel2
        case kernel3
        case kernel4
        case kernel5
        case kernel6
        case kernel7
        
        public func matches(_ other: Kernel) -> Bool {
            self == other ||
            self == .general ||
            other == .general
        }
        
        public var description: String {
            rawValue.capitalized
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
