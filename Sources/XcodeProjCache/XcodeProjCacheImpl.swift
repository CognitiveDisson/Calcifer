import Foundation
import Checksum
import XcodeProj
import PathKit
import Toolkit

public final class XcodeProjCacheImpl: XcodeProjCache {
    
    private let queue = DispatchQueue(label: "XcodeProjCache")
    private let checksumProducer: BaseURLChecksumProducer
    private var readCache = BaseCache<String, XcodeProjCacheValue<BaseChecksum>>()
    private var writableCache = StackCacheImpl<String, XcodeProjCacheValue<BaseChecksum>>() //<3
    private let fileManager: FileManager
    
    public static let shared: XcodeProjCacheImpl = {
        let fileManager = FileManager.default
        let checksumProducer = BaseURLChecksumProducer(fileManager: fileManager)
        return XcodeProjCacheImpl(
            fileManager: fileManager,
            checksumProducer: checksumProducer
        )
    }()
    
    private init(
        fileManager: FileManager,
        checksumProducer: BaseURLChecksumProducer)
    {
        self.fileManager = fileManager
        self.checksumProducer = checksumProducer
    }
    
    public func obtainXcodeProj(projectPath: String) throws -> XcodeProj {
        let xcodeProjCacheValue = try obtainCachedXcodeProj(
            projectPath: projectPath,
            cacheProvider: { readCache.obtain(for: $0) }
        )
        readCache.addValue(xcodeProjCacheValue, for: projectPath)
        return xcodeProjCacheValue.xcodeProj
    }
    
    public func obtainWritableXcodeProj(projectPath: String) throws -> XcodeProj {
        let xcodeProjCacheValue = try obtainCachedXcodeProj(
            projectPath: projectPath,
            cacheProvider: { writableCache.obtain(for: $0) }
        )
        writableCache.clear(for: projectPath) { cacheValue in
            guard cacheValue.modificationDate == xcodeProjCacheValue.modificationDate,
                cacheValue.checksum != xcodeProjCacheValue.checksum
                else { return true }
            return false
        }
        return xcodeProjCacheValue.xcodeProj
    }
    
    public func fillXcodeProjCache(projectPath: String) throws {
        _ = try obtainXcodeProj(projectPath: projectPath)
        try [0...3].forEach { _ in
            let xcodeProj = try obtainCachedXcodeProj(
                projectPath: projectPath,
                cacheProvider: { _ in return nil }
            )
            writableCache.addValue(xcodeProj, for: projectPath)
        }
    }
    
    private func obtainCachedXcodeProj(
        projectPath: String,
        cacheProvider: (String) -> (XcodeProjCacheValue<BaseChecksum>?))
        throws -> XcodeProjCacheValue<BaseChecksum>
    {
        return try queue.sync {
            let modificationDate = try obtainModificationDate(for: projectPath)
            let cacheValue = cacheProvider(projectPath)
            if let cacheValue = cacheValue,
                cacheValue.modificationDate == modificationDate {
                return cacheValue
            }
            
            let checksum = try obtainChecksum(for: projectPath)
            if let cacheValue = cacheValue,
                cacheValue.checksum == checksum {
                return cacheValue
            }
            
            let path = Path(projectPath)
            let xcodeProj = try XcodeProj(path: path)
     
            return XcodeProjCacheValue(
                xcodeProj: xcodeProj,
                checksum: checksum,
                modificationDate: modificationDate
            )
        }
    }
    
    private func obtainChecksum(for projectPath: String) throws -> BaseChecksum {
        let pbxprojPath = obtainPbxprojPath(for: projectPath)
        let pbxprojURL = URL(fileURLWithPath: pbxprojPath)
        let checksum = try checksumProducer.checksum(input: pbxprojURL)
        return checksum
    }
    
    private func obtainModificationDate(for projectPath: String) throws -> Date {
        let pbxprojPath = obtainPbxprojPath(for: projectPath)
        return try fileManager.modificationDate(at: pbxprojPath)
    }
    
    private func obtainPbxprojPath(for projectPath: String) -> String {
        let pbxprojPath = projectPath.appendingPathComponent("project.pbxproj")
        return pbxprojPath
    }
    
}
