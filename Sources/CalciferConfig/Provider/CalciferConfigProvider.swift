import Foundation
import Toolkit

public final class CalciferConfigProvider {
    
    private let calciferDirectory: String
    
    public init(calciferDirectory: String) {
        self.calciferDirectory = calciferDirectory
    }
    
    public func obtainGlobalConfig()  throws -> CalciferConfig {
        let path = globalConfigPath()
        let url = URL(fileURLWithPath: path)
        let jsonData = try Data(contentsOf: url)
        return try jsonData.decode()
    }
    
    public func obtainConfig(projectDirectoryPath: String) throws -> CalciferConfig {
        let defaultConfigDictionary = try CalciferConfig.defaultConfig(
            calciferDirectory: calciferDirectory
        ).toDictionary()
        let globalConfigDictionary = Dictionary.contentsOfFile(
            globalConfigPath()
        )
        let projectConfigDictionary = Dictionary.contentsOfFile(
            projectConfigPath(
                at: projectDirectoryPath,
                local: false
            )
        )
        let localProjectConfig = Dictionary.contentsOfFile(
            projectConfigPath(
                at: projectDirectoryPath,
                local: true
            )
        )
        let configDictionary = defaultConfigDictionary
            .override(by: globalConfigDictionary)
            .override(by: projectConfigDictionary)
            .override(by: localProjectConfig)
        return try configDictionary.toObject()
    }
    
    private func projectConfigPath(at projectDirectoryPath: String, local: Bool) -> String {
        return projectDirectoryPath
            .appendingPathComponent(configFileName(local: local))
    }
    
    private func globalConfigPath() -> String {
        return calciferDirectory
            .appendingPathComponent(configFileName(local: false))
    }
    
    private func configFileName(local: Bool) -> String {
        if local {
            return "CalciferConfig.local.json"
        } else {
            return "CalciferConfig.json"
        }
    }
    
}
