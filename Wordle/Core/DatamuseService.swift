//
//  DatamuseService.swift
//  Wordle
//
//  Created by Palina Skakun on 12/26/24.
//

import Foundation

struct DatamuseWord: Codable {
    let word: String
    let score: Int?
}

class DatamuseService {
    static let shared = DatamuseService()
    
    private init() { }

    /// Fetch up to 100 five-letter words from the Datamuse API, pick one at random, and call completion.
    func fetchRandomFiveLetterWord(completion: @escaping (String?) -> Void) {
        
        // Datamuse query for exactly 5-letter words (using ? for single letters)
        // &max=100 to limit the size of the response
        let urlString = "https://api.datamuse.com/words?sp=?????&max=100"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            // Check for networking errors
            if let error = error {
                print("Error fetching from Datamuse:", error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                // Decode JSON array of [DatamuseWord]
                let results = try JSONDecoder().decode([DatamuseWord].self, from: data)
                
                // Randomly pick a word from the results (if any were returned)
                let randomWord = results.randomElement()?.word
                completion(randomWord)
                
            } catch {
                print("Error decoding JSON:", error)
                completion(nil)
            }
        }.resume()
    }
    
    // In DatamuseService.swift:
    func isWordValid(_ word: String, completion: @escaping (Bool) -> Void) {
        // We'll query Datamuse with `?sp=theword` (exact match)
        // limit=1 so we don't waste bandwidth
        guard word.count == 5 else {
            completion(false)
            return
        }
        let urlString = "https://api.datamuse.com/words?sp=\(word)&max=1"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let _ = error {
                completion(false)
                return
            }
            guard let data = data else {
                completion(false)
                return
            }
            do {
                let results = try JSONDecoder().decode([DatamuseWord].self, from: data)
                // If the first result actually matches `word` exactly, we say it's valid
                let valid = results.first?.word.lowercased() == word.lowercased()
                completion(valid)
            } catch {
                completion(false)
            }
        }.resume()
    }

}
