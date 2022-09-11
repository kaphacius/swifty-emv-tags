import XCTest
@testable import SwiftyEMVTags
import SwiftyBERTLV

func mockTagData() throws -> Data {
    let url = URL(
        fileURLWithPath: Bundle.module.path(forResource: "tag_mock", ofType: "json")!
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

}
