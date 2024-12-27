//
//  WordleTests.swift
//  Wordle
//

import XCTest
@testable import Wordle

final class WordleTests: XCTestCase {
    func testComputeColorsForGuess() {
        let viewController = ViewController()
        
        // Test case: Perfect match
        let guess = ["s", "m", "i", "l", "e"]
        let answer = ["s", "m", "i", "l", "e"]
        let colors = viewController.computeColorsForGuess(guess.map { Character($0) }, answerChars: answer.map { Character($0) })
        XCTAssertEqual(colors, Array(repeating: UIColor.customGreen, count: 5))

        // Test case: No matches
        let guess2 = ["a", "b", "c", "d", "e"]
        let answer2 = ["x", "y", "z", "w", "v"]
        let colors2 = viewController.computeColorsForGuess(guess2.map { Character($0) }, answerChars: answer2.map { Character($0) })
        XCTAssertEqual(colors2, Array(repeating: UIColor.customBorderColor, count: 5))

        // Test case: Some matches
        let guess3 = ["s", "m", "i", "l", "e"]
        let answer3 = ["s", "p", "i", "c", "e"]
        let colors3 = viewController.computeColorsForGuess(guess3.map { Character($0) }, answerChars: answer3.map { Character($0) })
        XCTAssertEqual(colors3, [
            UIColor.customGreen,  // "s"
            UIColor.customBorderColor,  // "m"
            UIColor.customGreen,  // "i"
            UIColor.customBorderColor,  // "l"
            UIColor.customYellow   // "e"
        ])
    }

}
