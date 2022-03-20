import XCTest
@testable import SwiftyEMVTags
import SwiftyBERTLV

var infoSourceMock = MockInfoSource()

internal struct MockInfoSource: AnyEMVTagInfoSource {
    
    internal var onInfo: ((UInt64, EMVTag.Scheme) -> EMVTag.Info)?
    
    internal func info(for tag: UInt64, scheme: EMVTag.Scheme) -> EMVTag.Info {
        onInfo?(tag, scheme) ?? .unknown(tag: tag, scheme: scheme)
    }
    
}
