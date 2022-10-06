import XCTest
@testable import SwiftyEMVTags
import SwiftyBERTLV

func mockTagData() throws -> Data {
    let url = URL(
        fileURLWithPath: Bundle.module.path(forResource: "tag_mock", ofType: "json")!
    )
    return try Data(contentsOf: url)
}

func mockTagMappingData() throws -> Data {
    let url = URL(
        fileURLWithPath: Bundle.module.path(forResource: "tag_mapping_mock", ofType: "json")!
    )
    return try Data(contentsOf: url)
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

    static let mockResult: Self = .init(
        kernelName: "Mock kernel",
        tagInfo: .mockInfo,
        result: .success([]),
        extendedDescription: nil
    )
    
    static let mockErrorResult: Self = .init(
        kernelName: "Mock kernel",
        tagInfo: .mockInfo,
        result: .failure(EMVTagError.byteCountNotEqual),
        extendedDescription: nil
    )

}

extension TagInfo {
    
    static let mockInfo: Self = try! JSONDecoder().decode(
        TagInfo.self, from: mockJson.data(using: .utf8)!
    )
    
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
    
}
