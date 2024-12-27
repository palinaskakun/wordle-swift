//
//  DatamuseServiceTests.swift
//  Wordle
//
//  Created by Palina Skakun on 12/27/24.
//

import XCTest
@testable import Wordle

final class DatamuseServiceTests: XCTestCase {
    func testFetchRandomFiveLetterWord() {
        let expectation = XCTestExpectation(description: "Fetch random word")
        DatamuseService.shared.fetchRandomFiveLetterWord { word in
            XCTAssertNotNil(word, "Word should not be nil")
            XCTAssertEqual(word?.count, 5, "Word should be exactly 5 letters")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testIsWordValid() {
        let expectation = XCTestExpectation(description: "Check word validity")
        DatamuseService.shared.isWordValid("smile") { isValid in
            XCTAssertTrue(isValid, "\"smile\" should be valid")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}
