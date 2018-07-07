import XCTest
@testable import Shell

final class ShellTests: XCTestCase {
    func testBasePath() {
        let shell = Shell()

        XCTAssertEqual(shell.basePath(ofPath: "README.md"), "")
        XCTAssertEqual(shell.basePath(ofPath: "path/to/my/README.md"), "path/to/my")
        XCTAssertEqual(shell.basePath(ofPath: "/Users/gmosx/README.md"), "/Users/gmosx")
    }

    static var allTests = [
        ("testExample", testBasePath),
    ]
}
