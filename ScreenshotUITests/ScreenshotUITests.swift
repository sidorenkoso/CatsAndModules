import XCTest

@MainActor
final class ScreenshotUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)          // provided by SnapshotHelper.swift
        app.launch()
    }

    func testTakeScreenshots() throws {
        let app = XCUIApplication()

        // The app asks for crash-reporting consent on first launch — dismiss it
        // so it doesn't cover the list in the screenshots.
        let allow = app.alerts.buttons["Allow"]
        if allow.waitForExistence(timeout: 5) {
            allow.tap()
        }

        // ----- Main screen (the list) -----
        let firstRow = app.cells.firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 30), "List did not load")
        sleep(3) // let the thumbnails finish loading for a nicer shot
        snapshot("Sofiia_MainScreen")

        // ----- Details screen (full-screen image) -----
        firstRow.tap()
        sleep(3) // let the full image load
        snapshot("Sofiia_DetailsScreen")
    }
}
