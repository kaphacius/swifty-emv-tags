import XCTest
@testable import SwiftyEMVTags
import SwiftyBERTLV

var mockTagData:  Data {
    get throws {
        let url = URL(
            fileURLWithPath: Bundle.module.path(forResource: "tag_mock", ofType: "json")!
        )
        return try Data(contentsOf: url)
    }
}

var mockTagMappingData: Data {
    get throws {
        let url = URL(
            fileURLWithPath: Bundle.module.path(forResource: "tag_mapping_mock", ofType: "json")!
        )
        return try Data(contentsOf: url)
    }
}

var mockKernelInfoData: Data {
    get throws {
        let url = URL(
            fileURLWithPath: Bundle.module.path(forResource: "general_kernel_mock", ofType: "json")!
        )
        return try Data(contentsOf: url)
    }
}

enum TestError: Error {
    
    case unableToFindValue(type: String, key: String)
    
}

extension Dictionary where Key == String, Value == Any {
    
    func value<T>(for key: String) throws -> T {
        guard let value = self[key] as? T else {
            throw TestError.unableToFindValue(type: "\(T.self)", key: key)
        }
        
        return value
    }
    
    func value<T>(of type: T.Type, for key: String) throws -> T {
        try self.value(for: key)
    }
    
}

typealias JSONDictionary = Dictionary<String, Any>

extension EMVTag.DecodedTag {
    
    static var mockResult: Self {
        .init(
            kernel: "mock",
            tagInfo: .mockInfo,
            result: .success([]),
            extendedDescription: nil
        )
    }
    
    static var mockContextBoundResult: Self {
        .init(
            kernel: "mock",
            tagInfo: .mockContextBoundInfo,
            result: .success([]),
            extendedDescription: nil
        )
    }
    
    static var mockErrorResult: Self {
        .init(
            kernel: "mock",
            tagInfo: .mockInfo,
            result: .failure(EMVTagError.byteCountNotEqual),
            extendedDescription: nil
        )
    }

}

extension TagInfo {
    
    static var mockInfo: Self {
        try! JSONDecoder().decode(
            Self.self, from: mockJson.data(using: .utf8)!
        )
    }
    
    static var mockContextBoundInfo: Self {
        try! JSONDecoder().decode(
            Self.self, from: mockContextBoundJson.data(using: .utf8)!
        )
    }
    
    static let mockJson = """
    {
        "description": "This is a very special tag with all sorts of patters and encodings",
        "format": "binary",
        "kernel": "general",
        "maxLength": "3",
        "minLength": "3",
        "name": "Very special tag",
        "source": "card",
        "tag": "9F0A"
    }
    """
    
    static let mockContextBoundJson = """
    {
        "description": "This is a very special tag and it is context bound",
        "format": "binary",
        "kernel": "general",
        "maxLength": "3",
        "minLength": "3",
        "name": "Very special tag",
        "source": "card",
        "tag": "9F0A",
        "context": "E1"
    }
    """
    
}
 
extension KernelInfo {
    
    static var mockGeneralKernelInfo: Self {
        try! JSONDecoder().decode(
            Self.self, from: mockKernelInfoData
        )
    }
    
}
