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
    
    var currentRow = 0
    private var currentIndex = 0

    let keyboardVC = KeyboardViewController()
    let boardVC = BoardViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBackground
        
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
        addChild(keyboardVC)
        keyboardVC.didMove(toParent: self)
        keyboardVC.delegate = self
        keyboardVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboardVC.view)

        addChild(boardVC)
        boardVC.didMove(toParent: self)
        boardVC.view.translatesAutoresizingMaskIntoConstraints = false
        boardVC.datasource = self
        view.addSubview(boardVC.view)

        NSLayoutConstraint.activate([
            boardVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            boardVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            boardVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            boardVC.view.bottomAnchor.constraint(equalTo: keyboardVC.view.topAnchor),
            boardVC.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),

            keyboardVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    // MARK: - Gameplay
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
                    // Mark the row as submitted
                    self.currentRow += 1
                    self.currentIndex = 0
                    self.checkForWinOrLose()
                    
                    // reload board so we see final colors
                    self.boardVC.reloadData()
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
        }
        // Lose?
        else if currentRow == 6 {
            showAlert(title: "Game Over",
                      message: "The correct word was \(answer.uppercased())")
        }
    }

    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - Keyboard Delegate
extension ViewController: KeyboardViewControllerDelegate {
    func keyboardViewController(_ vc: KeyboardViewController, didTapKey key: String) {
        if key == "ENTER" {
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
