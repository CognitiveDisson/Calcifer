import Foundation

public final class CalciferPathProviderImpl: CalciferPathProvider {
    
    private let fileManager: FileManager
    
    public init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
    
    public func calciferDirectory() -> String {
        // .noindex - remove from spotlight index
        return fileManager
            .home()
            .appendingPathComponent(".calcifer.noindex")
    }
    
    public func calciferBinaryName() -> String {
        return "Calcifer"
    }
    
    public func calciferBinaryPath() -> String {
        return calciferDirectory()
            .appendingPathComponent(calciferBinaryName())
    }
    
    public func calciferChecksumFilePath() -> String {
        return calciferDirectory()
            .appendingPathComponent("сhecksum.json")
    }
    
    public func calciferEnvironmentFilePath() -> String {
        return calciferDirectory()
            .appendingPathComponent("calciferenv.json")
    }
    
    public func calciferBuildLogDirectory() -> String {
        return calciferDirectory()
            .appendingPathComponent("buildlogs")
    }
    
    public func launchAgentPlistPath(label: String) -> String {
        return fileManager.home()
            .appendingPathComponent("Library")
            .appendingPathComponent("LaunchAgents")
            .appendingPathComponent("\(label).plist")
    }
    
    public func launchctlStandardOutPath() -> String {
        return calciferDirectory()
            .appendingPathComponent("launchctl")
            .appendingPathComponent("out.txt")
    }
    
    public func launchctlStandardErrorPath() -> String {
        return calciferDirectory()
            .appendingPathComponent("launchctl")
            .appendingPathComponent("error.txt")
    }
    
}
