import Foundation
import XcodeProjCache
import Checksum

final class XcodeProjChecksumHolderBuilderFactory {
    
    private let fullPathProvider: FileElementFullPathProvider
    private let xcodeProjCache: XcodeProjCache
    
    init(fullPathProvider: FileElementFullPathProvider, xcodeProjCache: XcodeProjCache) {
        self.fullPathProvider = fullPathProvider
        self.xcodeProjCache = xcodeProjCache
    }
    
    func projChecksumHolderBuilder<ChecksumCache: XcodeProjChecksumCache>(
        checksumProducer: URLChecksumProducer<ChecksumCache.ChecksumType>,
        xcodeProjChecksumCache: ChecksumCache)
        -> XcodeProjChecksumHolderBuilder<ChecksumCache>
    {
        return XcodeProjChecksumHolderBuilder(
            xcodeProjCache: xcodeProjCache,
            xcodeProjChecksumCache: xcodeProjChecksumCache,
            checksumProducer: checksumProducer,
            fullPathProvider: fullPathProvider
        )
    }
}
