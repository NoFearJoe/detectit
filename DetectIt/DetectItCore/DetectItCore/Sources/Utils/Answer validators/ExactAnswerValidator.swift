//
//  ExactAnswerValidator.swift
//  DetectItCore
//
//  Created by Илья Харабет on 21.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import Foundation

/*
 Алгоритм зачета ответа:
 - получаем ключевые слова из строки с ответом используя разделители: пробел, запятая
 - очищаем каждое ключевое слово от лишних символов: пробелов, кавычек
 - делаем тоже самое с правильными ответами
 - каждое ключевое слово из ответа пользователя находим среди ключевых слов правильного ответа:
   - сравниваем без учета регистра, без различий между "е"-"ё" и "и"-"й"
 - получаем на выходе структуру, где описаны все совпадения
 - если все совпадения верны, ответ считаем правильным
 */

struct ExactAnswerValidator {
    
    private struct Constants {
        static let minMatchPercent = 0.5
        static let keywordsSeparators = [" ", ",", "-"]
        static let insignificantChars = ["\"", "'", "«", "»"]
        static let maxTyposCount = 1
    }
    
    private let correctAnswers: [String]
    
    init(correctAnswers: [String]) {
        self.correctAnswers = correctAnswers
    }
    
    func validate(answer: String) -> Bool {
        compareWholeAnswer(answer: answer) ||
        compareByKeywords(answer: answer)
    }
    
    // MARK: Check whole answer
    
    /// Проверка наличия введенных пользователем слов в полном ответе
    private func compareWholeAnswer(answer: String) -> Bool {
        if correctAnswers.contains(answer) {
            return true
        }
        
        if let specialTimesComparisionResult = compareSpecialTypes(answer: answer).bool {
            return specialTimesComparisionResult
        }
        
        let answerKeywords = getKeywords(answer: answer)
        
        return answerKeywords
            .matches { userKeyword in
                correctAnswers.contains {
                    isWord(userKeyword, containsIn: $0)
                }
            }
            .matchPercent(totalKeywords: answerKeywords.count) >= Constants.minMatchPercent
    }
    
    /// Проверка ответов на совпадение по ключевым словам
    private func compareByKeywords(answer: String) -> Bool {
        let answerKeywords = getKeywords(answer: answer)
        let correctAnswerKeywords = correctAnswers.flatMap { getKeywords(answer: $0) }.unique
        
        return answerKeywords
            .matches { userKeyword in
                correctAnswerKeywords.contains {
                    areWordsEqual(lhs: userKeyword, rhs: $0)
                }
            }
            .matchPercent(totalKeywords: answerKeywords.count) >= Constants.minMatchPercent
    }
    
    // MARK: - Utils
    
    private func clear(_ answer: String) -> String {
        answer
            .filter {
                !$0.isWhitespace &&
                !$0.isNewline &&
                !Constants.insignificantChars.contains(String($0))
            }
            .trimmingCharacters(in: .punctuationCharacters)
            .lowercased()
    }
    
    private func isWord(_ word: String, containsIn string: String) -> Bool {
        clear(string).contains(word)
    }
    
    private func areWordsEqual(lhs _lhs: String, rhs _rhs: String) -> Bool {
        let lhs = clear(_lhs)
        let rhs = clear(_rhs)
        
        if let specialTimesComparisionResult = compareSpecialTypes(answer: lhs).bool {
            return specialTimesComparisionResult
        } else {
            return (
                lhs.compare(
                    rhs,
                    options: [.caseInsensitive, .diacriticInsensitive]
                ) == .orderedSame && getPunctuationTyposCount(_lhs, _rhs) == 0
            ) || (
                getTyposCount(lhs, rhs) <= Constants.maxTyposCount && getPunctuationTyposCount(_lhs, _rhs) == 0
            )
        }
    }
    
    private func compareSpecialTypes(answer: String) -> MatchingResult {
        let matchers: [SpecialTypeMatcher] = [NumberMatcher(), DateMatcher(), TimeMatcher()]
        
        let matchingResults = correctAnswers.flatMap { correctAnswer in
            matchers.map {
                $0.match(userAnswer: answer, correctAnswer: correctAnswer)
            }
        }
        
        guard
            matchingResults.allSatisfy({ $0 == .skipped })
        else {
            return .init(
                matchingResults.contains(.equal)
            )
        }
        
        return .skipped
    }
    
    private func getKeywords(answer: String) -> [String] {
        answer
            .split { Constants.keywordsSeparators.contains(String($0)) }
            .map { clear(String($0)) }
    }
    
    /// Используется илгоритм Левинштейна
    func getTyposCount(_ _w1: String, _ _w2: String) -> Int {
        let w1 = String(_w1.unicodeScalars.filter { !CharacterSet.punctuationCharacters.contains($0) })
        let w2 = String(_w2.unicodeScalars.filter { !CharacterSet.punctuationCharacters.contains($0) })
        
        let empty = [Int](repeating:0, count: w2.count)
        var last = [Int](0...w2.count)

        for (i, char1) in w1.enumerated() {
            var cur = [i + 1] + empty
            for (j, char2) in w2.enumerated() {
                cur[j + 1] = char1 == char2 ? last[j] : min(last[j], last[j + 1], cur[j]) + 1
            }
            last = cur
        }
        
        return last.last ?? 0
    }
    
    func getPunctuationTyposCount(_ _w1: String, _ _w2: String) -> Int {
        let w1 = String(_w1.unicodeScalars.filter { !CharacterSet.punctuationCharacters.union(.whitespacesAndNewlines).contains($0) })
        let w2 = String(_w2.unicodeScalars.filter { !CharacterSet.punctuationCharacters.union(.whitespacesAndNewlines).contains($0) })
        
        return abs((_w1.count - w1.count) - (_w2.count - w2.count))
    }
    
}

struct KeywordMatch {
    let keyword: String
    let isCorrect: Bool
}

private extension Array where Element == KeywordMatch {
    
    func matchPercent(totalKeywords: Int) -> Double {
        let matchesCount = self.filter { $0.isCorrect }.count
        return Double(matchesCount).safeDivide(by: Double(totalKeywords))
    }
    
}

private extension Array where Element == String {
    
    func matches(isCorrect: (String) -> Bool) -> [KeywordMatch] {
        self.map { userKeyword in
            KeywordMatch(
                keyword: userKeyword,
                isCorrect: isCorrect(userKeyword)
            )
        }
    }
    
}
