//
//  TagDecoder.swift
//  
//
//  Created by Yurii Zadoianchuk on 11/09/2022.
//

import SwiftyBERTLV
import Foundation

public protocol AnyTagDecoder {
    
    var tagMapper: TagMapper { get }
    var activeKernels: [KernelInfo] { get }
    
    func decodeBERTLV(_ bertlv: BERTLV) -> EMVTag
    
}

extension AnyTagDecoder {
    
    public func decodeBERTLV(_ bertlv: BERTLV) -> EMVTag {
        .init(
            bertlv: bertlv,
            decodingResult: decodingResult(for: bertlv),
            subtags: decodeSubtags(bertlv.subTags)
        )
    }
    
    private func decodingResult(for bertlv: BERTLV) -> EMVTag.DecodingResult {
        activeKernels
            .compactMap { kernel -> EMVTag.DecodingResult? in
                kernel.decodeTag(
                    bertlv,
                    tagMapper: tagMapper
                )
                .map(EMVTag.DecodingResult.singleKernel)
            }.flattenDecodingResults()
    }
    
    private func decodeSubtags(_ subtags: [BERTLV]) -> [EMVTag.DecodedSubtag] {
        guard subtags.isEmpty == false else { return [] }
        
        return subtags.map {
            .init(
                result: decodingResult(for: $0),
                subtags: decodeSubtags($0.subTags)
            )
        }
    }
    
}

public final class TagDecoder: AnyTagDecoder {
    
    public let tagMapper: TagMapper
    
    public var activeKernels: [KernelInfo] { kernelsInfo.values.sorted() }
    
    private (set) public var kernelsInfo: [String: KernelInfo]
    internal (set) public var kernelIds: [String]
    
    internal init(
        kernelInfoList: [KernelInfo],
        tagMapper: TagMapper
    ) {
        self.kernelIds = kernelInfoList.map(\.id)
        self.kernelsInfo = .init(
            uniqueKeysWithValues: kernelInfoList.map { ($0.id, $0) }
        )
        self.tagMapper = tagMapper
    }
    
    public static func defaultDecoder() throws -> TagDecoder {
        let decoder = JSONDecoder()
        let kernelInfoList = try KernelInfo.defaultURLs()
            .map { try Data(contentsOf: $0) }
            .map { try decoder.decode(KernelInfo.self, from: $0) }
        let mapper = try TagMapper.defaultMapper()
        return .init(
            kernelInfoList: kernelInfoList,
            tagMapper: mapper
        )
    }
    
    public func addKernelInfo(newInfo: KernelInfo) throws {
        guard kernelIds.contains(newInfo.name) == false else {
            throw EMVTagError.kernelInfoAlreadyExists(name: newInfo.name)
        }
        
        kernelIds.append(newInfo.name)
        kernelsInfo[newInfo.name] = newInfo
    }
    
    public func removeKernelInfo(with name: String) {
        guard let idx = kernelIds.firstIndex(of: name) else {
            return
        }
        
        kernelIds.remove(at: idx)
        kernelsInfo.removeValue(forKey: name)
    }
    
}

extension KernelInfo: Comparable, Equatable {
    
    public static func == (lhs: KernelInfo, rhs: KernelInfo) -> Bool {
        lhs.id == rhs.id
    }
    
    public static func < (lhs: KernelInfo, rhs: KernelInfo) -> Bool {
        lhs.id < rhs.id
    }
    
}

extension KernelInfo {
    
    internal static let defaultKernelInfoCount = 6
    
    internal static func defaultURLs() throws -> [URL] {
        try defaultJSONResources(.kernelInfo)
    }
    
}


extension Array where Element == EMVTag.DecodingResult {
    
    internal func flattenDecodingResults() -> EMVTag.DecodingResult {
        switch (count, first) {
        case (0, _):
            // If there are no results - tag is unknown
            return .unknown
            // If there is only one result - use it
        case (1, .some(let result)):
            return result
        case (_, _):
            // If there are multiple results, group them
            let flattened: [EMVTag.DecodedTag] = self.reduce([]) { (result, current) in
                switch current {
                case .unknown, .multipleKernels:
                    return result
                case .singleKernel(let decodedTag):
                    return result + [decodedTag]
                }
            }
            
            if flattened.isEmpty {
                return .unknown
            } else if flattened.count == 1, let first = flattened.first {
                return .singleKernel(first)
            } else {
                return .multipleKernels(flattened)
            }
        }
    }
    
}
