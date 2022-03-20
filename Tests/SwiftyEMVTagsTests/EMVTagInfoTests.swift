import XCTest
@testable import SwiftyEMVTags
import SwiftyBERTLV

final class EMVTagInfoTests: XCTestCase {
    
    func testProduceUnknownTagInfoAllSchemes() throws {
        
        let sut = EMVTag.Info.info(for: 0x00, scheme: .all)
        
        XCTAssertEqual(sut, .unknown(tag: 0x00, scheme: .all))
        
    }
    
    func testProduceUnknownTagInfoSpecificSchemes() throws {
        
        let sut = EMVTag.Info.info(for: 0x00, scheme: .jcb)
        
        XCTAssertEqual(sut, .unknown(tag: 0x00, scheme: .jcb))
        
    }
    
    func testUsesProvidedDataSource() throws {
        
        let expectedTag: UInt64 = 0x5A
        let expectedScheme = EMVTag.Scheme.visa
        
        let expectation = expectation(description: "Expect info to be requested")
        
        var mockSource = infoSourceMock
        mockSource.onInfo = { (tag, scheme) in
            XCTAssertEqual(tag, expectedTag)
            XCTAssertEqual(scheme, expectedScheme)
            
            expectation.fulfill()
            
            return EMVTag.Info.unknown(tag: tag, scheme: scheme)
        }
        
        let sut = EMVTag.Info.info(
            for: expectedTag,
               scheme: expectedScheme,
               infoSource: mockSource
        )
        
        XCTAssertEqual(
            sut,
            EMVTag.Info.unknown(tag: expectedTag, scheme: expectedScheme)
        )
        
        waitForExpectations(timeout: 0.0, handler: nil)
        
    }
    
}
