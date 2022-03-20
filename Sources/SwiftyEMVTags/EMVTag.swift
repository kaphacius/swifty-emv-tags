//
//  SwiftyEMVTags.swift
//
//
//  Created by Yurii Zadoianchuk on 16/03/2022.
//

import SwiftyBERTLV

public struct EMVTag {
    
    public let tag: UInt64
    public let name: String
    public let description: String
    public let source: Source
    public let format: Format
    public let scheme: Scheme
    
    public let isConstructed: Bool
    public let value: [UInt8]
    public let subtags: [EMVTag]
    
    init(tlv: BERTLV, scheme: Scheme = .all) {
        
        let info: Info = .info(for: tlv.tag, scheme: scheme)
        
        self.tag = tlv.tag
        self.name = info.name
        self.description = info.description
        self.source = info.source
        self.format = info.format
        self.scheme = info.scheme
        
        self.isConstructed = tlv.isConstructed
        self.value = tlv.value
        if self.isConstructed {
            self.subtags = tlv.subTags.map { .init(tlv: $0, scheme: scheme) }
        } else {
            self.subtags = []
        }
    }
    
}

// source: kernel, terminal, card (ICC), config, issuer
// description
// format: binary, date, any other format
// scheme: regular or scheme-specific. some tags have different meaning per scheme

extension EMVTag {
    
    public enum Source {
        case unknown
        case kernel
        case terminal
        case card
        case config
        case issuer
    }
    
    public enum Format {
        case unknown
        case binary
        case BCD
        case date
    }
    
    public struct Scheme: OptionSet, Hashable, CaseIterable {
        
        public static let allCases: [EMVTag.Scheme] = [
            .mastercard, .visa, .americanExpress, .jcb, .discover, .unionPay
        ]
        
        public static let mastercard = Scheme(rawValue: 1 << 0)
        public static let visa = Scheme(rawValue: 1 << 1)
        public static let americanExpress = Scheme(rawValue: 1 << 2)
        public static let jcb = Scheme(rawValue: 1 << 3)
        public static let discover = Scheme(rawValue: 1 << 4)
        public static let unionPay = Scheme(rawValue: 1 << 5)
        public static let all = Scheme(
            rawValue: Scheme.allCases
                            .map(\.rawValue)
                            .reduce(0, |)
        )
        
        public let rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    
    }
    
}
