//
// ViewController.swift
// Wordle
//

import UIKit

class ViewController: UIViewController {

    var answer = ""
    
    /// 6 rows x 5 columns
    private var guesses: [[Character?]] = Array(
        repeating: Array(repeating: nil, count: 5),
        count: 6
    )
    
    /// A dictionary for storing each letter's "best color so far".
    /// Keys are single-letter strings like "a", "b", "c" ...
    private var keyColors: [String: UIColor] = [:]
    
    var currentRow = 0
    private var currentIndex = 0

    let keyboardVC = KeyboardViewController()
    let boardVC = BoardViewController()

    // 1) A button that is initially hidden
    private let newGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NEW GAME", for: .normal)
        button.backgroundColor = .customBorderColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true  // hidden until the game ends
        return button
        }()

        // 2) Add a method to set up constraints for this button
        private func setupNewGameButtonConstraints() {
        NSLayoutConstraint.activate([
            newGameButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGameButton.heightAnchor.constraint(equalToConstant: 44),
            newGameButton.widthAnchor.constraint(equalToConstant: 120),
        ])
        }
    
    @objc private func didTapNewGame() {
            startNewGame()
        }
        
        private func startNewGame() {
            newGameButton.isHidden = true
            currentRow = 0
            currentIndex = 0
            guesses = Array(repeating: Array(repeating: nil, count: 5), count: 6)
            
            DatamuseService.shared.fetchRandomFiveLetterWord { [weak self] fetchedWord in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.answer = fetchedWord ?? "smile"
                    print("New answer is:", self.answer)
                    self.boardVC.reloadData()
                }
            }
        }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBackground
        
        // 3) Add the button to the view
        view.addSubview(newGameButton)
        // Add target
        newGameButton.addTarget(self, action: #selector(didTapNewGame), for: .touchUpInside)

        
        // Fetch a random 5-letter word from Datamuse
        DatamuseService.shared.fetchRandomFiveLetterWord { [weak self] fetchedWord in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.answer = fetchedWord ?? "smile"
                print("Answer is:", self.answer)
                self.addChildren()
            }
        }
    }

    private func addChildren() {
        // 1) Board as a child
        addChild(boardVC)
        boardVC.didMove(toParent: self)
        boardVC.view.translatesAutoresizingMaskIntoConstraints = false
        boardVC.datasource = self
        view.addSubview(boardVC.view)

        // 2) Keyboard as a child
        addChild(keyboardVC)
        keyboardVC.didMove(toParent: self)
        keyboardVC.delegate = self
        keyboardVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardVC.view)

        // 3) Board constraints
        NSLayoutConstraint.activate([
            boardVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            boardVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            boardVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Give the board about half the screen’s height
            boardVC.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])

        // 4) “New Game” button constraints
        // We'll move setupNewGameButtonConstraints() calls here so
        // we can place it AFTER we know where the board is
        view.addSubview(newGameButton) // ensure it's on top
        NSLayoutConstraint.activate([
            newGameButton.topAnchor.constraint(equalTo: boardVC.view.bottomAnchor, constant: 16),
            newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGameButton.heightAnchor.constraint(equalToConstant: 44),
            newGameButton.widthAnchor.constraint(equalToConstant: 120),
        ])

        // 5) Keyboard constraints
        NSLayoutConstraint.activate([
            // The keyboard’s top is below the button’s bottom
            keyboardVC.view.topAnchor.constraint(equalTo: newGameButton.bottomAnchor, constant: 16),
            keyboardVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    
    // Gameplay
    private func handleEnterPressed() {
        // Must have typed exactly 5 letters
        guard currentIndex == 5 else {
            showAlert(title: "Not enough letters", message: "You need 5 letters to submit.")
            return
        }
        
        let currentGuessChars = guesses[currentRow].compactMap { $0 }
        let guessString = String(currentGuessChars)

        // Query Datamuse to verify it's a valid word
        DatamuseService.shared.isWordValid(guessString) { [weak self] isValid in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if !isValid {
                    // Show alert, do NOT move on
                    self.showAlert(title: "Invalid Word",
                                   message: "\"\(guessString.uppercased())\" is not recognized.")
                } else {

                    // 2) The guess is valid, so compute the colors for the row
                    let answerChars = Array(self.answer)
                    let rowColors = self.computeColorsForGuess(currentGuessChars, answerChars: answerChars)
                                        
                    // 3) Update the key-colors dictionary
                    self.updateKeyboardColors(guessChars: currentGuessChars, colors: rowColors)
                    
                    self.keyboardVC.letterColorDict = self.keyColors
                    self.keyboardVC.reloadKeys()
                    
                    
                    // Mark the row as submitted
                    self.currentRow += 1
                    self.currentIndex = 0
                    self.checkForWinOrLose()
                    
                    // reload board so we see final colors
                    self.boardVC.reloadData()
                    
                    // 5) Refresh keyboard colors
                    self.keyboardVC.letterColorDict = self.keyColors
                    
                    // 6) Reload the keyboard so it updates its key colors
                    self.keyboardVC.reloadKeys()
                }
            }
        }
    }
    
    /// Merges a single row of color results into `keyColors`.
    /// e.g. if letter was found Green, it overrides any prior Yellow.
    private func updateKeyboardColors(guessChars: [Character], colors: [UIColor]) {
        for i in 0..<5 {
            let letter = guessChars[i]
            let color = colors[i]
            let letterString = String(letter).lowercased() // e.g. "a"
            
            // If we have no color stored yet, store it
            guard let existingColor = keyColors[letterString] else {
                keyColors[letterString] = color
                continue
            }
            
            // If we do have an existing color, pick the "best" one
            // Priority: Green > Yellow > Gray
            if existingColor == .customGreen {
                // Do nothing, as we can't override green with lesser color
            }
            else if existingColor == .customYellow {
                // If new color is green, override
                if color == .customGreen {
                    keyColors[letterString] = .customGreen
                }
                // else remain yellow
            }
            else {
                // existing color is Gray or none
                // so if new color is green or yellow, override
                if color == .customGreen || color == .customYellow {
                    keyColors[letterString] = color
                }
            }
        }
    }

    
    private func handleDelPressed() {
        
        // Only delete if we have letters to delete in current row
            if currentIndex > 0 {
                // Move back one space
                currentIndex -= 1
                // Remove the letter at that position
                guesses[currentRow][currentIndex] = nil
            }
        
    }

    private func handleLetterPressed(_ letter: String) {
        guard let firstChar = letter.first else { return }
        // If there's still room in the current row
        if currentIndex < 5 && currentRow < 6 {
            guesses[currentRow][currentIndex] = firstChar
            currentIndex += 1
        }
    }
    
    private func checkForWinOrLose() {
        let currentGuessChars = guesses[currentRow - 1].compactMap { $0 }
        let guessString = String(currentGuessChars)
        
        // Win?
        if guessString.lowercased() == answer.lowercased() {
            showAlert(title: "Congratulations!",
                      message: "You guessed the word \(answer.uppercased())")
            newGameButton.isHidden = false
        }
        // Lose?
        else if currentRow == 6 {
            showAlert(title: "Game Over",
                      message: "The correct word was \(answer.uppercased())")
            newGameButton.isHidden = false
        }
    }

    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// Keyboard Delegate
extension ViewController: KeyboardViewControllerDelegate {
    func keyboardViewController(_ vc: KeyboardViewController, didTapKey key: String) {
        if key == "ENT" {
            handleEnterPressed()
        }
        else if key == "DEL"{
            handleDelPressed()
        }
        else {
            handleLetterPressed(key)
        }
        
        // Reload after every key press or after "ENTER" to update letters on the board
        boardVC.reloadData()
    }
}

// MARK: - Board DataSource
extension ViewController: BoardViewControllerDatasource {
    
    var currentGuesses: [[Character?]] {
        return guesses
    }

    // Board wants to know the color of the cell at row/col
    func boxColor(at indexPath: IndexPath) -> UIColor? {
        let row = indexPath.section
        let col = indexPath.row
        
        // If the row isn't submitted yet, no color
        guard row < currentRow else {
            return nil
        }
        
        // Make sure we have a full guess
        let guessChars = guesses[row].compactMap { $0 }
        guard guessChars.count == 5 else {
            return nil
        }
        
        let answerChars = Array(answer)
        let colors = computeColorsForGuess(guessChars, answerChars: answerChars)
        return colors[col]
    }
    
    // Two-pass color logic
    private func computeColorsForGuess(_ guessChars: [Character], answerChars: [Character]) -> [UIColor] {
        var colors = Array(repeating: UIColor.customBorderColor, count: 5)
        var frequency = [Character: Int]()
        
        // First pass: mark greens, build freq from unmatched letters in 'answer'
        for i in 0..<5 {
            let g = guessChars[i]
            let a = answerChars[i]
            if g == a {
                colors[i] = .customGreen
            } else {
                // Only build frequency from answer letters that aren't matched
                frequency[a, default: 0] += 1
            }
        }
        
        // Second pass: mark yellows for letters that exist in the leftover frequency
        for i in 0..<5 {
            if colors[i] == .customGreen { continue }
            let g = guessChars[i]
            if let count = frequency[g], count > 0 {
                colors[i] = .customYellow
                frequency[g] = count - 1
            }
        }
        
        return colors
    }
}
