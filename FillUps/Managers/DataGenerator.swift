//
//  DataGenerator.swift
//  FillUps
//
//  Created by Keshav Bansal on 08/10/19.
//  Copyright © 2019 kb. All rights reserved.
//

import Foundation

public typealias ExtractCallback = ((String) -> ())

class DataGenerator {
    
    public typealias TextCallback = ((String) -> ())

    var originalExtract: String?
    var omittedExtract: String?
    
    var originalSentences = [String]()
    var omittedSentences = [String]()
    
    var omittedWords = [String]()
    var shuffledWords: [String] {
        get {
            return self.omittedWords.shuffled()
        }
    }
    
    func getRandomWikiText(completion: @escaping ExtractCallback, errorCallback: ErrorCallback?) {
        let url = "https://en.wikipedia.org/w/api.php?action=query&generator=random&grnnamespace=0&prop=extracts&explaintext&redirects=1&format=json&exsentences=10"
        NetworkManager.shared.fetchJSONData(forUrl: url, completion: { (data: WikiResult) in
            if let extract = data.getExtract() {
                let plainExtract = self.getPlainExtract(forExtract: extract)
                var sentences = plainExtract.getSentences()
                if sentences.count < 10 {
                    // The random generator api of wikipedia even with the parameter of exsentences=10 might give less than 10 sentences. So we make another api call
                    self.getRandomWikiText(completion: completion, errorCallback: errorCallback)
                } else {
                    sentences.removeSubrange(10...)
                    self.originalExtract = plainExtract
                    self.originalSentences = sentences
                    self.generateBlanks()
                    if let ommittedExtract = self.omittedExtract {
                        completion(ommittedExtract)
                    }
                }
            }
        }) { (error) in
            errorCallback?(error)
        }
    }
    
    func getPlainExtract(forExtract extract: String) -> String {
        let regex = try! NSRegularExpression(pattern: "==.*==", options: [])
        let range = NSMakeRange(0, extract.count)
        let modString = regex.stringByReplacingMatches(in: extract, options: [], range: range, withTemplate: "")
        return modString.replacingOccurrences(of: "\n", with: "", options: .regularExpression)
    }
    
    func generateBlanks() {
        self.omittedWords.removeAll()
        self.omittedSentences.removeAll()
        for sentence in self.originalSentences {
            if let newWord = sentence.getRandomWord(excludingWords: self.omittedWords) {
                self.omittedWords.append(newWord)
                let omittedSentence = sentence.replacingFirstOccurrence(of: newWord, withString: "_______")
                self.omittedSentences.append(omittedSentence)
            }
        }
        self.omittedExtract = self.omittedSentences.joined(separator: ". ")
    }
    
    func getFinalScore(forAnswers answers: [Int: String]) -> Int {
        var score = 0
        for element in answers {
            let index = element.key
            if index < self.omittedWords.count {
                if element.value == self.omittedWords[index] {
                    score += 1
                }
            }
        }
        return score
    }

}
