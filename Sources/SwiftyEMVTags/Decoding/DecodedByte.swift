//
//  DecodedByte.swift
//  
//
//  Created by Yurii Zadoianchuk on 08/09/2022.
//

import Foundation

public enum EMVTagError: Error {
    case unableToLoadResources(String)
    case unableToDecodeGroup(byte: UInt8, groupName: String)
    case kernelInfoAlreadyExists(name: String)
    case tagMappingAlreadyExists(tag: UInt64)
    case byteCountNotEqual
}

extension EMVTag {
    
    /// Represents a decoded byte
    public struct DecodedByte: Equatable {
        
        /// The name of the byte, if applicable
        public let name: String?
        
        /// The list of decoded groups
        public let groups: [Group]
        
        /// Initialize using provided byte value and ``ByteInfo``
        /// Marches the byte value according to the ``ByteInfo/Group`` provided in `info`
        /// - Parameters:
        ///   - byte: `UInt8` representation of the byte value
        ///   - info: ``ByteInfo`` describing decoding groups
        public init(byte: UInt8, info: ByteInfo) throws {
            self.name = info.name
            self.groups = try info.groups
                .map { try .init(byte: byte, group: $0) }
        }
        
    }
    
}

extension EMVTag.DecodedByte {
    
    /// Represents one decoded group within a byte
    public struct Group: Equatable {
        
        /// Name of the group
        public let name: String
        
        /// Type of the mapping of the group
        public let type: GroupType
        
        /// Lowest ``width`` bits represent the actual bit mapping
        public let pattern: UInt8
        
        /// The bit width of the group
        public let width: Int
        
        /// Initializes group with a given byte value and ``ByteInfo/Group``
        /// - Parameters:
        ///   - byte: `UInt8` representation of the byte value
        ///   - group: ``ByteInfo/Group`` describing the decoding group
        public init(byte: UInt8, group: ByteInfo.Group) throws {
            let shiftedBits = byte.extractingBits(with: group.pattern)

            guard let type = GroupType(group: group, shiftedBits: shiftedBits.extracted) else {
                throw EMVTagError.unableToDecodeGroup(byte: byte, groupName: group.name)
            }
            
            self.type = type
            self.pattern = shiftedBits.extracted
            self.width = shiftedBits.patternWidth
            self.name = group.name
        }
        
        public enum GroupType: Equatable {
            case bitmap(MappingResult)
            case hex(UInt8)
            case bcd(UInt8)
            case bool(Bool)
            case RFU
            
            init?(group: ByteInfo.Group, shiftedBits: UInt8) {
                switch group.type {
                case .bool:
                    self = .bool(shiftedBits == 1)
                case .hex:
                    self = .hex(shiftedBits)
                case .RFU:
                    self = .RFU
                case .bitmap(let mappings):
                    if let index = mappings
                        .map(\.pattern)
                        .firstIndex(where: { shiftedBits.matches(pattern: $0) }) {
                        self = .bitmap(.init(mappings: mappings, matchIndex: index))
                    } else {
                        return nil
                    }
                }
            }
        }
        
        public struct MappingResult: Equatable {
            public let mappings: [SingleMapping]
            public let matchIndex: Int
            
            fileprivate init(mappings: [ByteInfo.Group.Mapping], matchIndex: Int) {
                self.mappings = mappings.map(SingleMapping.init(mapping:))
                self.matchIndex = matchIndex
            }
            
            public struct SingleMapping: Equatable {
                public let pattern: UInt8
                public let meaning: String
                
                fileprivate init(mapping: ByteInfo.Group.Mapping) {
                    self.pattern = mapping.pattern
                    self.meaning = mapping.meaning
                }
            }
        }
        
    }
    
}
