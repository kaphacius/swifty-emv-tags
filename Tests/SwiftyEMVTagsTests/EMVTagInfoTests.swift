import XCTest
@testable import SwiftyEMVTags
import SwiftyBERTLV

final class EMVTagInfoTests: XCTestCase {
    
    func testUsesProvidedDataSource() throws {
        
        let expectedTag: UInt64 = 0x5A
        let expectedKernel = EMVTag.Kernel.kernel1
        
        let expectation = expectation(description: "Expect info to be requested")
        
        var mockSource = infoSourceMock
        mockSource.onInfo = { (tag, kernel) in
            XCTAssertEqual(tag, expectedTag)
            XCTAssertEqual(kernel, expectedKernel)
            
            expectation.fulfill()
            
            return EMVTag.Info.unknown(tag: tag)
        }
        
        _ = EMVTag(
            tlv: try .parse(bytes: [UInt8(expectedTag), 0x00]).first!,
            kernel: expectedKernel,
            infoSource: mockSource
        )
        
        waitForExpectations(timeout: 0.0, handler: nil)
        
    }
    
}
