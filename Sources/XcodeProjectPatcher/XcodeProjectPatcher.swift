import Foundation
import PathKit
import XcodeProj
import XcodeProjCache

public final class XcodeProjectPatcher {
    
    private let xcodeProjCache: XcodeProjCache
    
    public init(xcodeProjCache: XcodeProjCache) {
        self.xcodeProjCache = xcodeProjCache
    }
    
    public func patch(projectPath: String, outputPath: String, targets: [String]) throws {
        let xcodeproject = try xcodeProjCache.obtainXcodeProj(projectPath: projectPath)
        let pbxproj = xcodeproject.pbxproj
        guard let project = try pbxproj.rootProject() else { return }
        patchBuildSetting(in: project.buildConfigurationList)
        let agregateTarget = PBXAggregateTarget(
            name: "Aggregate",
            buildConfigurationList: project.buildConfigurationList
        )
        patchBuildSetting(in: agregateTarget.buildConfigurationList)
        var targetsForRemoving = [String]()

        project.targets.enumerated().forEach { index, target in
            if targets.contains(target.name) {
                patchBuildSetting(in: target.buildConfigurationList)
                let dependency = PBXTargetDependency(
                    name: target.name,
                    target: target,
                    targetProxy: nil
                )
                pbxproj.add(object: dependency)
                agregateTarget.dependencies.append(dependency)
            } else {
                targetsForRemoving.append(target.name)
            }
        }
        targetsForRemoving.forEach { targetName in
            if let index = project.targets.firstIndex(where: { $0.name == targetName }) {
                // This is necessary because of an error about duplication of heders
                // (One inside the framework, the other in the source).
                // Perhaps this can be corrected in another way.
                let target = project.targets[index]
                for buildPhase in target.buildPhases {
                    pbxproj.delete(object: buildPhase)
                }
                removeGroup(for: target, pbxproj: pbxproj, project: project)
                if let product = target.product {
                    pbxproj.delete(object: product)
                }

                project.targets.remove(at: index)
            }
        }
        pbxproj.add(object: agregateTarget)
        project.targets.append(agregateTarget)
        try xcodeproject.write(path: Path(outputPath))
    }
    
    private func removeGroup(for target: PBXTarget, pbxproj: PBXProj, project: PBXProject) {
        let podsGroup = project.mainGroup.group(named: "Pods")
        let developmentPodsGroup = project.mainGroup.group(named: "Development Pods")
        if let targetGroup = podsGroup?.group(named: target.name) {
            pbxproj.delete(object: targetGroup)
        }
        if let targetGroup = developmentPodsGroup?.group(named: target.name) {
            pbxproj.delete(object: targetGroup)
        }
        if let productName = target.productName {
            if let targetGroup = podsGroup?.group(named: productName) {
                pbxproj.delete(object: targetGroup)
            }
            if let targetGroup = developmentPodsGroup?.group(named: productName) {
                pbxproj.delete(object: targetGroup)
            }
        }
        if let productName = target.product?.name {
            if let productGroup = project.productsGroup?.group(named: productName) {
                pbxproj.delete(object: productGroup)
            }
        }
    }
    
    func patchBuildSetting(in buildConfigurationList: XCConfigurationList?) {
        guard let buildConfigurations = buildConfigurationList?.buildConfigurations
            else { return }
        for buildConfiguration in buildConfigurations {
            for (key, value) in buildSettings() {
                buildConfiguration.buildSettings[key] = value
            }
        }
    }
    
    func buildSettings() -> BuildSettings {
        return [
            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
            "GCC_GENERATE_DEBUGGING_SYMBOLS": "YES"
        ]
    }
    
}
