//
//  WordleUITests.swift
//  WordleUITests
//

import XCTest

final class WordleUITests: XCTestCase {
    func testKeyboardInteraction() throws {
        let app = XCUIApplication()
        app.launch()

        // Ensure keyboard appears
        let textField = app.textFields["WordInputField"] // Replace with the actual identifier
        XCTAssertTrue(textField.exists)
        textField.tap()

        // Test key taps
        for char in "abcde" {
            let key = app.keys[String(char).uppercased()]
            XCTAssertTrue(key.exists)
            key.tap()
        }
    }

    func testWordSubmission() throws {
        let app = XCUIApplication()
        app.launch()

        // Simulate typing a valid word
        for char in "smile" {
            app.keys[String(char).uppercased()].tap()
        }
        app.buttons["ENT"].tap()
        
        // Check for success alert
        XCTAssertTrue(app.alerts["Congratulations!"].exists)
    }
}
