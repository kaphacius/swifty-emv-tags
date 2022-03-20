import XCTest
@testable import SwiftyEMVTags
import SwiftyBERTLV

final class EMVTagTests: XCTestCase {
    
    func testInitPrimitiveTLVAllSchemes() throws {
        
        let tlv = try XCTUnwrap(BERTLV.parse(bytes: [0x5A, 0x01, 0xBB]).first)
        
        let sut = EMVTag(tlv: tlv)
        
        XCTAssertEqual(sut.tag, tlv.tag)
        XCTAssertEqual(sut.isConstructed, tlv.isConstructed)
        XCTAssertEqual(sut.value, tlv.value)
        XCTAssertEqual(sut.subtags.count, tlv.subTags.count)
        XCTAssertEqual(sut.scheme, .all)
        
    }
    
    func testInitConstructedTLVAllSchemes() throws {
        
        let subTlv = try XCTUnwrap(BERTLV.parse(bytes: [0x5A, 0x01, 0xFF]).first)
        let tlv = try XCTUnwrap(BERTLV.parse(bytes: [0xE1, 0x03, 0x5A, 0x01, 0xFF]).first)
        
        let sut = EMVTag(tlv: tlv)
        
        XCTAssertEqual(sut.tag, tlv.tag)
        XCTAssertEqual(sut.isConstructed, tlv.isConstructed)
        XCTAssertEqual(sut.value, tlv.value)
        XCTAssertEqual(sut.subtags.count, tlv.subTags.count)
        
        let sutSubTag = try XCTUnwrap(sut.subtags.first)
        XCTAssertEqual(sutSubTag.tag, subTlv.tag)
        XCTAssertEqual(sutSubTag.isConstructed, subTlv.isConstructed)
        XCTAssertEqual(sutSubTag.value, subTlv.value)
        XCTAssertEqual(sutSubTag.subtags.count, subTlv.subTags.count)
        XCTAssertEqual(sutSubTag.scheme, .all)
        
    }
    
    func testInitPrimitiveTLVSpecificScheme() throws {
        
        let tlv = try XCTUnwrap(BERTLV.parse(bytes: [0x5A, 0x01, 0xBB]).first)
        
        let sut = EMVTag(tlv: tlv, scheme: .jcb)
        
        XCTAssertEqual(sut.isConstructed, tlv.isConstructed)
        XCTAssertEqual(sut.value, tlv.value)
        XCTAssertEqual(sut.subtags.count, tlv.subTags.count)
        XCTAssertEqual(sut.scheme, .jcb)
        
    }
    
    func testInitConstructedTLVSpecificScheme() throws {
        
        let subTlv = try XCTUnwrap(BERTLV.parse(bytes: [0x5A, 0x01, 0xFF]).first)
        let tlv = try XCTUnwrap(BERTLV.parse(bytes: [0xE1, 0x03, 0x5A, 0x01, 0xFF]).first)
        
        let sut = EMVTag(tlv: tlv, scheme: .discover)
        
        XCTAssertEqual(sut.tag, tlv.tag)
        XCTAssertEqual(sut.isConstructed, tlv.isConstructed)
        XCTAssertEqual(sut.value, tlv.value)
        XCTAssertEqual(sut.subtags.count, tlv.subTags.count)
        
        let sutSubTag = try XCTUnwrap(sut.subtags.first)
        XCTAssertEqual(sutSubTag.tag, subTlv.tag)
        XCTAssertEqual(sutSubTag.isConstructed, subTlv.isConstructed)
        XCTAssertEqual(sutSubTag.value, subTlv.value)
        XCTAssertEqual(sutSubTag.subtags.count, subTlv.subTags.count)
        XCTAssertEqual(sutSubTag.scheme, .discover)
        
    }
    
}
