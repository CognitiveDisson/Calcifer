import Foundation
import XCTest
import Toolkit
import Mock
import XcodeBuildEnvironmentParametersParser
@testable import Warmer

public final class XcodeProjCacheWarmerTests: BaseTestCase {
    
    func test_warmup() throws {
        // Given
        let stubedCalciferDirectory = createTmpDirectory()
        let calciferPathProviderStub = CalciferPathProviderStub(
            fileManager: fileManager
        )
        let podsRoot = createTmpDirectory()
        calciferPathProviderStub.stubedCalciferDirectory = stubedCalciferDirectory.path
        let params = try XcodeBuildEnvironmentParameters.forTests(
            podsRoot: podsRoot.path
        )
        try params.save(to: calciferPathProviderStub.calciferEnvironmentFilePath())
        let xcodeProjCache = XcodeProjCacheStub()
        var fillXcodeProjCacheProjectPath: String?
        xcodeProjCache.onFillXcodeProjCache = { projectPath in
            fillXcodeProjCacheProjectPath = projectPath
        }
        let xcodeProjCacheWarmer = XcodeProjCacheWarmer(
            xcodeProjCache: xcodeProjCache,
            calciferPathProvider: calciferPathProviderStub
        )
        let events: WarmerEvent = .initial
        // When
        xcodeProjCacheWarmer.warmup(for: events) { operation in
            operation.start()
        }
        // Then
        XCTAssertNotNil(fillXcodeProjCacheProjectPath)
    }
    
}
