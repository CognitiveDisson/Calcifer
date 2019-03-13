import Foundation
import Checksum

public final class BuildArtifactIntegrator {
    
    private let fileManager: FileManager
    private let checksumProducer: BaseURLChecksumProducer
    
    public init(
        fileManager: FileManager,
        checksumProducer: BaseURLChecksumProducer)
    {
        self.fileManager = fileManager
        self.checksumProducer = checksumProducer
    }
    
    public func integrate<ChecksumType: Checksum>(
        artifacts: [TargetBuildArtifact<ChecksumType>],
        to path: String) throws
    {
        try artifacts.forEach { artifact in
            let artifactDestination = obtainDestination(for: artifact, at: path)
            let artifactCurrentURL = URL(fileURLWithPath: artifact.path)
            if try compareArtifacts(artifactCurrentURL, artifactDestination) == false {
                if fileManager.directoryExist(at: artifactDestination) {
                    try fileManager.removeItem(at: artifactDestination)
                }
                let artifactDestinationFolderURL = artifactDestination.deletingLastPathComponent()
                if fileManager.directoryExist(at: artifactDestinationFolderURL) == false {
                    try fileManager.createDirectory(
                        at: artifactDestinationFolderURL,
                        withIntermediateDirectories: true
                    )
                }
                try fileManager.copyItem(
                    at: artifactCurrentURL,
                    to: artifactDestination
                )
            }
        }
    }
    
    private func compareArtifacts(
        _ artifactPath: URL,
        _ artifactDestination: URL)
        throws -> Bool
    {
        if fileManager.fileExists(atPath: artifactDestination.path) == false {
            return false
        }
        let artifactChecksum = try checksumProducer.checksum(input: artifactPath)
        let destinationChecksum = try checksumProducer.checksum(input: artifactDestination)
        return artifactChecksum == destinationChecksum
    }
    
    private func obtainDestination<ChecksumType: Checksum>(
        for artifact: TargetBuildArtifact<ChecksumType>,
        at path: String)
        -> URL
    {
        return URL(
            fileURLWithPath: path.appendingPathComponent(
                artifact.targetInfo.targetName
            )
        )
    }
    
}
