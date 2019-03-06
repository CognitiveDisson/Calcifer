import Foundation
import xcodeproj
import PathKit

final class ProjChecksumHolderBuilder<Builder: URLChecksumProducer> {
    
    let builder: ProjectChecksumHolderBuilder<Builder>
    
    init(builder: ProjectChecksumHolderBuilder<Builder>) {
        self.builder = builder
    }
    
    func build(pbxproj: PBXProj, sourceRoot: Path) throws -> ProjChecksumHolder<Builder.C> {
        let projectsChecksums = try pbxproj.projects.map { project in
            try builder.build(project: project, sourceRoot: sourceRoot)
        }
        let checksum = try projectsChecksums.checksum()
        return ProjChecksumHolder<Builder.C>(
            projects: projectsChecksums,
            checksum: checksum
        )
    }
}