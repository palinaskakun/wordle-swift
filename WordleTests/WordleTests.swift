//
//  WordleTests.swift
//  Wordle
//
//  Created by Palina Skakun on 12/27/24.
//

import XCTest
@testable import Wordle

final class WordleTests: XCTestCase {
    // MARK: - ViewController Tests
    func testComputeColorsForGuess() {
        let viewController = ViewController()
        let guess = ["s", "m", "i", "l", "e"]
        let answer = ["s", "h", "a", "r", "p"]
        let colors = viewController.computeColorsForGuess(guess.map { Character($0) }, answerChars: answer.map { Character($0) })
        
        XCTAssertEqual(colors[0], UIColor.customGreen, "First letter should be green")
        XCTAssertEqual(colors[1], UIColor.customBorderColor, "Second letter should be gray")
        XCTAssertEqual(colors[2], UIColor.customBorderColor, "Third letter should be gray")
        XCTAssertEqual(colors[3], UIColor.customBorderColor, "Fourth letter should be gray")
        XCTAssertEqual(colors[4], UIColor.customBorderColor, "Fifth letter should be gray")
    }
    
    // MARK: - UI Tests
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testKeyboardInteraction() throws {
        let app = XCUIApplication()
        app.launch()
        
        let keyA = app.keys["A"]
        let keyB = app.keys["B"]
        let keyC = app.keys["C"]
        keyA.tap()
        keyB.tap()
        keyC.tap()
        
        let boardCellA = app.staticTexts["A"]
        let boardCellB = app.staticTexts["B"]
        let boardCellC = app.staticTexts["C"]
        XCTAssertTrue(boardCellA.exists, "A should appear on the board")
        XCTAssertTrue(boardCellB.exists, "B should appear on the board")
        XCTAssertTrue(boardCellC.exists, "C should appear on the board")
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
