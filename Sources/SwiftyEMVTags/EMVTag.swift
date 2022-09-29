//
//  SwiftyEMVTags.swift
//
//
//  Created by Yurii Zadoianchuk on 16/03/2022.
//

import SwiftyBERTLV
import Foundation

public struct EMVTag {
    
    public enum DecodingResult {
        case unknown
        case error(Error)
        case singleKernel(DecodedTag)
        case multipleKernels([DecodedTag])
    }
    
    public struct DecodedTag {
        public let kernelName: String
        public let tagInfo: TagInfo
        public let decodedBytes: [DecodedByte]
    }
    
    public struct DecodedSubtag {
        public let result: DecodingResult
        public let subtags: [DecodedSubtag]
    }
    
    public let tag: BERTLV
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
        self.lengthBytes = tlv.lengthBytes
        
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
        lengthBytes: [UInt8],
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
        self.lengthBytes = lengthBytes
        self.subtags = subtags
        self.decodedMeaningList = decodedMeaningList
    }
    
    public var hexString: String {
        [
            tag.hexString,
            lengthBytes.map(\.hexString).joined(),
            value.map(\.hexString).joined()
        ].joined()
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

    public let decodingResult: DecodingResult
    
    public init(
        bertlv: BERTLV,
        decodingResult: DecodingResult,
        subtags: [DecodedSubtag]
    ) {
        self.tag = bertlv
        self.decodingResult = decodingResult
        
        guard bertlv.isConstructed else {
            self.subtags = []
            return
        }
        
        self.subtags = zip(bertlv.subTags, subtags)
            .map { (bertlvSubtag, decodedSubtag) in
                .init(
                    bertlv: bertlvSubtag,
                    decodingResult: decodedSubtag.result,
                    subtags: decodedSubtag.subtags
                )
            }
    }
    
    public init(
        bertlv: BERTLV,
        decodingResult: DecodingResult
    ) {
        self.tag = bertlv
        self.decodingResult = decodingResult
        self.subtags = []
    }
    
    public static func unknownTag(bertlv: BERTLV) -> EMVTag {
        .init(bertlv: bertlv, decodingResult: .unknown)
    }
    
}

extension EMVTag.DecodedTag: Equatable {}

extension EMVTag.DecodingResult: Equatable {
    
    static public func == (lhs: Self, rhs: Self) -> Bool {
        switch(lhs, rhs) {
        case (.unknown, .unknown):
            return true
        case (.error(let lerror), .error(let rerror)):
            return areEqual(lerror, rerror)
        case (.singleKernel(let llhs), .singleKernel(let rrhs)):
            return llhs == rrhs
        case (.multipleKernels(let llhs), .multipleKernels(let rrhs)):
            return llhs == rrhs
        default:
            return false
        }
    }
    
}
