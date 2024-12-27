//
//  WordleUITests.swift
//  WordleUITests
//
//  Created by Palina Skakun on 12/26/24.
//

import XCTest

final class WordleUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testKeyboardInteraction() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Simulate tapping a text field to make the keyboard appear
        let textField = app.textFields["WordInputField"] // Replace with your text field's identifier
        XCTAssertTrue(textField.exists, "Text field should exist")
        textField.tap()
        
        // Check keyboard visibility
        XCTAssertTrue(app.keyboards.count > 0, "Keyboard should be visible")
        
        // Tap keys
        let keyA = app.keys["A"]
        XCTAssertTrue(keyA.exists, "Key 'A' should exist")
        keyA.tap()

        let keyB = app.keys["B"]
        XCTAssertTrue(keyB.exists, "Key 'B' should exist")
        keyB.tap()

        let keyC = app.keys["C"]
        XCTAssertTrue(keyC.exists, "Key 'C' should exist")
        keyC.tap()
    }


    func testWordSubmission() throws {
        let app = XCUIApplication()
        app.launch()
        
        for char in "smile" {
            app.keys[String(char).uppercased()].tap()
        }
        app.buttons["ENT"].tap()
        
        let successAlert = app.alerts["Congratulations!"]
        XCTAssertTrue(successAlert.exists, "Winning alert should appear when the game is won")
    }

    func testInvalidWordAlert() throws {
        let app = XCUIApplication()
        app.launch()
        
        for char in "zzzzz" {
            app.keys[String(char).uppercased()].tap()
        }
        app.buttons["ENT"].tap()
        
        let invalidAlert = app.alerts["Invalid Word"]
        XCTAssertTrue(invalidAlert.exists, "Invalid Word alert should appear for incorrect submissions")
    }

    func testGameOverAlert() throws {
        let app = XCUIApplication()
        app.launch()
        
        for _ in 1...6 {
            for char in "wrong" {
                app.keys[String(char).uppercased()].tap()
            }
            app.buttons["ENT"].tap()
        }
        
        let gameOverAlert = app.alerts["Game Over"]
        XCTAssertTrue(gameOverAlert.exists, "Game Over alert should appear after six incorrect guesses")
    }

    func testGameReset() throws {
        let app = XCUIApplication()
        app.launch()
        
        for char in "abcde" {
            app.keys[String(char).uppercased()].tap()
        }
        
        app.buttons["NEW GAME"].tap()
        
        let boardCell = app.staticTexts["A"]
        XCTAssertFalse(boardCell.exists, "The board should reset after starting a new game")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
