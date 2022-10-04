//
//  TagDecoder.swift
//  
//
//  Created by Yurii Zadoianchuk on 11/09/2022.
//

import SwiftyBERTLV
import Foundation

public protocol AnyTagDecoder {
    
    func decodeBERTLV(_ bertlv: BERTLV) -> EMVTag
    
}

public final class TagDecoder: AnyTagDecoder {
    
    private var kernelsInfo: [String: KernelInfo]
    
    internal (set) public var kernels: [String]
    
    internal init(kernelInfoList: [KernelInfo]) {
        self.kernels = kernelInfoList.map(\.name)
        self.kernelsInfo = .init(
            uniqueKeysWithValues: kernelInfoList.map { ($0.name, $0) }
        )
    }
    
    public static func defaultDecoder() throws -> TagDecoder {
        let decoder = JSONDecoder()
        let kernelInfoList = try KernelInfo.defaultURLs()
            .map { try Data(contentsOf: $0) }
            .map { try decoder.decode(KernelInfo.self, from: $0) }
        return .init(kernelInfoList: kernelInfoList)
    }
    
    public func addKernelInfo(data: Data) throws {
        let newInfo = try JSONDecoder().decode(KernelInfo.self, from: data)
        
        guard kernels.contains(newInfo.name) == false else {
            throw EMVTagError.kernelInfoAlreadyExists(name: newInfo.name)
        }
        
        kernels.append(newInfo.name)
        kernelsInfo[newInfo.name] = newInfo
    }
    
    public func decodeBERTLV(_ bertlv: BERTLV) -> EMVTag {
        .init(
            bertlv: bertlv,
            decodingResult: decodingResult(for: bertlv),
            subtags: decodeSubtags(bertlv.subTags)
        )
    }
    
    private func decodingResult(for bertlv: BERTLV) -> EMVTag.DecodingResult {
        kernelsInfo
            .values
            .compactMap { kernel -> EMVTag.DecodingResult? in
                kernel.decodeTag(bertlv)
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

extension KernelInfo {
    
    internal static let defaultKernelInfoCount = 6
    
    internal static func defaultURLs() throws -> [URL] {
        guard let urls = Bundle.module.urls(
            forResourcesWithExtension: "json",
            subdirectory: nil
        ) else {
            throw EMVTagError.unableToFindDefaultKernelInfos
        }
        
        return urls
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
