import XCTest
@testable import SwiftyEMVTags
import SwiftyBERTLV

var infoSourceMock = MockInfoSource()

internal struct MockInfoSource: AnyEMVTagInfoSource {
    
    internal var onInfo: ((UInt64, EMVTag.Kernel) -> EMVTag.Info)?
    
    internal func info(for tag: UInt64, kernel: EMVTag.Kernel) -> EMVTag.Info {
        onInfo?(tag, kernel) ?? .unknown(tag: tag)
    }
    
}

extension EMVTag.Info {
    
    internal static func mockInfo(with kernel: EMVTag.Kernel) -> EMVTag.Info {
        EMVTag.Info(
            tag: 0x5A,
            name: "",
            description: "",
            source: .kernel,
            format: "",
            kernel: kernel,
            minLength: "",
            maxLength: "", byteMeaningList: [
                (0..<UInt8.bitWidth).map { _ in "" },
                (0..<UInt8.bitWidth).map { _ in "" },
                (0..<UInt8.bitWidth).map { _ in "" }
            ]
        )
    }

}
