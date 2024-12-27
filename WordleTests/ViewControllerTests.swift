//
//  ViewControllerTests.swift
//  Wordle
//
//  Created by Palina Skakun on 12/27/24.
//

import XCTest
@testable import Wordle

final class ViewControllerTests: XCTestCase {
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
}
