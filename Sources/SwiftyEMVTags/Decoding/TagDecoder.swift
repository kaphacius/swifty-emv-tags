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
    func updateDecodingResults(for tags: [EMVTag]) -> [EMVTag]
    
}

extension AnyTagDecoder {
    
    public func decodeBERTLV(_ bertlv: BERTLV) -> EMVTag {
        .init(
            bertlv: bertlv,
            decodingResult: decodingResult(for: bertlv, context: nil),
            subtags: decodeSubtags(bertlv.subtags, context: bertlv.tag)
        )
    }
    
    public func updateDecodingResults(for tags: [EMVTag]) -> [EMVTag] {
        tags
            .map { ($0, self.decodeBERTLV($0.tag)) }
            .map { $0.0.updatingDecodingResult(with: $0.1) }
    }
    
    private func decodingResult(
        for bertlv: BERTLV,
        context: UInt64?
    ) -> EMVTag.DecodingResult {
        activeKernels
            .compactMap { kernel -> EMVTag.DecodingResult? in
                kernel.decodeTag(
                    bertlv,
                    tagMapper: tagMapper,
                    context: context
                )
                .map(EMVTag.DecodingResult.singleKernel)
            }.flattenDecodingResults(context: context)
    }
    
    private func decodeSubtags(
        _ subtags: [BERTLV],
        context: UInt64
    ) -> [EMVTag.DecodedSubtag] {
        guard subtags.isEmpty == false else { return [] }
        
        return subtags.map {
            .init(
                result: decodingResult(for: $0, context: context),
                subtags: decodeSubtags($0.subtags, context: $0.tag)
            )
        }
    }
    
}

public final class TagDecoder: AnyTagDecoder {
    
    public let tagMapper: TagMapper
    
    public var activeKernels: [KernelInfo] { kernelsInfo.values.sorted() }
    
    private(set) public var kernelsInfo: [String: KernelInfo]
    internal(set) public var kernelIds: [String]
    
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
        guard kernelIds.contains(newInfo.id) == false else {
            throw EMVTagError.kernelInfoAlreadyExists(id: newInfo.id)
        }
        
        kernelIds.append(newInfo.id)
        kernelsInfo[newInfo.id] = newInfo
    }
    
    public func removeKernelInfo(with id: String) {
        guard let idx = kernelIds.firstIndex(of: id) else {
            return
        }
        
        kernelIds.remove(at: idx)
        kernelsInfo.removeValue(forKey: id)
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

extension BERTLV {
    
    fileprivate var subtags: [BERTLV] {
        switch category {
        case .plain: return []
        case .constructed(let subtags): return subtags
        }
    }
    
}

extension Array where Element == EMVTag.DecodingResult {
    
    internal func flattenDecodingResults(
        context: UInt64?
    ) -> EMVTag.DecodingResult {
        switch (count, first) {
        case (0, _):
            // If there are no results - tag is unknown
            return .unknown
            // If there is only one result - use it
        case (1, .some(let result)):
            return result
        case (_, _):
            // If there are multiple results, group them
            // Skip any unknowns
            let flattened: [EMVTag.DecodedTag] = self.reduce([]) { (result, current) in
                switch current {
                case .unknown:
                    return result
                case .multipleKernels(let decodedTags):
                    // Should not be here
                    return result + decodedTags
                case .singleKernel(let decodedTag):
                    return result + [decodedTag]
                }
            }
            
            if flattened.isEmpty {
                // If no results from any kernel - tag is unknown
                return .unknown
            } else if flattened.count == 1, let first = flattened.first {
                // If only one result - one result it is
                return .singleKernel(first)
            } else {
                // If context is present - check if any results match the context
                if let context {
                    let contextFiltered = flattened.filter { $0.tagInfo.context == context }
                    if contextFiltered.isEmpty {
                        // If no results match the context - return all of the results
                        return .multipleKernels(flattened)
                    } else {
                        // Flatten the remainig results without context
                        return contextFiltered
                            .map(EMVTag.DecodingResult.singleKernel)
                            .flattenDecodingResults(context: nil)
                    }
                } else {
                    return .multipleKernels(flattened)
                }
            }
        }
    }
    
}
