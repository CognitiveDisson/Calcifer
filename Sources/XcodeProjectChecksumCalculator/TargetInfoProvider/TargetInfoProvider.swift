import Foundation
import Checksum

public final class TargetInfoProvider<ChecksumType: Checksum> {
    
    private let checksumHolder: XcodeProjChecksumHolder<ChecksumType>
    private let fileManager: FileManager
    
    init(
        checksumHolder: XcodeProjChecksumHolder<ChecksumType>,
        fileManager: FileManager)
    {
        self.checksumHolder = checksumHolder
        self.fileManager = fileManager
    }
    
    public func dependencies(
        for target: String,
        buildParametersChecksum: ChecksumType) throws -> [TargetInfo<ChecksumType>] {
        guard let checksumHolder = targetChecksumHolder({ $0.targetName == target }) else {
            throw XcodeProjectChecksumCalculatorError.emptyTargetChecksum(targetName: target)
        }
        let allFlatDependencies = checksumHolder.allFlatDependencies
        let result: [TargetInfo<ChecksumType>] = try allFlatDependencies.map({ targetChecksumHolder in
            let targeChecksum = try targetChecksumHolder.checksum + buildParametersChecksum
            return TargetInfo(
                targetName: targetChecksumHolder.targetName,
                productName: targetChecksumHolder.productName,
                productType: targetChecksumHolder.productType,
                dependencies: targetChecksumHolder.dependencies.map { $0.targetName },
                checksum: targeChecksum
            )
        })
        return result
    }
    
    public func targetInfo(
        for productName: String,
        buildParametersChecksum: ChecksumType)
        throws -> TargetInfo<ChecksumType>
    {
        guard let checksumHolder = targetChecksumHolder({ $0.productName == productName }) else {
            throw XcodeProjectChecksumCalculatorError.emptyProductChecksum(
                productName: productName
            )
        }
        let targeChecksum = try checksumHolder.checksum + buildParametersChecksum
        return TargetInfo(
            targetName: checksumHolder.targetName,
            productName: checksumHolder.productName,
            productType: checksumHolder.productType,
            dependencies: checksumHolder.dependencies.map { $0.targetName },
            checksum: targeChecksum
        )
    }
    
    public func saveChecksumToFile() throws {
        let data = try checksumHolder.encode()
        let outputFilePath = fileManager.calciferDirectory()
            .appendingPathComponent("checkum.json")
        let outputFileURL = URL(fileURLWithPath: outputFilePath)
        try data.write(to: outputFileURL)
    }

    private func targetChecksumHolder(
        _ filter: (TargetChecksumHolder<ChecksumType>) -> (Bool)
        ) -> TargetChecksumHolder<ChecksumType>?
    {
        return targetChecksumHolders().first {
            return filter($0)
        }
    }
    
    private func targetChecksumHolders() -> [TargetChecksumHolder<ChecksumType>] {
        return checksumHolder.proj.projects.flatMap({ $0.targets })
    }
    
}