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
        if let specialTimesComparisionResult = compareSpecialTypes(answer: answer).bool {
            return specialTimesComparisionResult
        }
        
        let answerKeywords = getKeywords(answer: answer)
        
        let matchesByAnswer = correctAnswers.map { _correctAnswer -> Bool in
            var correctAnswer = clear(_correctAnswer)
            
            let matches = answerKeywords.map { answerKeyword -> KeywordMatch in
                var isCorrect = false
                if let rangeOfKeyword = correctAnswer.range(of: answerKeyword, options: [.caseInsensitive, .diacriticInsensitive]) {
                    correctAnswer.removeSubrange(rangeOfKeyword)
                    isCorrect = true
                }
                
                return KeywordMatch(
                    keyword: answerKeyword,
                    isCorrect: isCorrect
                )
            }
            
            let matchesCoverage = matches.reduce(0) { $0 + ($1.isCorrect ? $1.keyword.count : 0) }
            let extraMatchesCoverage = matches.reduce(0) { $0 + ($1.isCorrect ? 0 : $1.keyword.count) }
            
            let matchPercent = Double(matchesCoverage) / Double(_correctAnswer.count)
            let extraMatchPercent = Double(extraMatchesCoverage) / Double(_correctAnswer.count)
            
            // ПРАВИЛО: совпадения должны покрывать не меньше чем 80% от ответа
            return matchPercent >= 0.8 && extraMatchPercent <= 0.5
        }
        
        return matchesByAnswer.contains(true)
    }
    
    func compareByKeywords(answer: String) -> Bool {
        typealias OneKeywordMatch = (typosCount: Int, keywordIndex: Int)
        typealias AnswerKeywordsMatches = (index: Int, OneKeywordMatch?)
        typealias MatchQuality = (missing: Int, matching: Int, extra: Int)
        
        /// Поиск максимально совпадающего слова в списке ключевых слов одного ответа
        /// Если нет подходящих слов, возвращаем nil
        func findBestKeywordMatch(userKeyword: String, answerKeywords: [String], exceptIndexes: [Int]) -> OneKeywordMatch? {
            let matches = answerKeywords.enumerated().map { (index, answerKeyword) -> (equal: Bool, typos: Int, index: Int) in
                guard !exceptIndexes.contains(index) else { return (false, 0, index) }
                
                if areWordsEqual(lhs: userKeyword, rhs: answerKeyword) {
                    return (true, 0, index)
                } else {
                    let typosCount = getTyposCount(userKeyword, answerKeyword)
                    let punctuationTyposCount = getPunctuationTyposCount(userKeyword, answerKeyword)
                    
                    let isEqualByLength = clear(userKeyword).count == clear(answerKeyword).count
                    let areTyposSatisfiesLimit = typosCount <= Constants.maxTyposCount && punctuationTyposCount == 0
                    return (isEqualByLength && areTyposSatisfiesLimit, typosCount + punctuationTyposCount, index)
                }
            }
            
            let _bestMatch = matches.min(by: { $0.equal && !$1.equal || $0.typos < $1.typos })
            
            guard let bestMatch = _bestMatch, bestMatch.equal, bestMatch.typos <= Constants.maxTyposCount else { return nil }
            
            return (bestMatch.typos, bestMatch.index)
        }
        
        /// Составление списка всех пользовательских ключевых слов и их совпадений
        func findAllMatches(userKeywords: [String], answerKeywords: [String]) -> [AnswerKeywordsMatches] {
            var matches = [AnswerKeywordsMatches]()
            
            userKeywords.enumerated().forEach { index, userKeyword in
                let bestMatch = findBestKeywordMatch(
                    userKeyword: userKeyword,
                    answerKeywords: answerKeywords,
                    exceptIndexes: matches.compactMap { $0.1?.keywordIndex }
                )
                
                matches.append((index, bestMatch))
            }
            
            return matches
        }
        
        /// Функция, которая проверяет, что все ключевые слова в варианте ответа есть в ключевых словах пользователя
        func matchQuality(matches: [AnswerKeywordsMatches], correctAnswerKeywords: [String]) -> MatchQuality {
            // Ключевые слова, у которых нет совпадений в ключевых словах из ответа
            var extraMatches = matches
            var missing = 0
            var matching = 0
            correctAnswerKeywords.enumerated().forEach { index, keyword in
                let _matchIndex = extraMatches.firstIndex { matchIndex, match -> Bool in
                    if let match = match {
                        return match.keywordIndex == index
                    } else {
                        return false
                    }
                }
                
                guard let matchIndex = _matchIndex else {
                    missing += 1
                    return
                }
                
                extraMatches.remove(at: matchIndex)
                
                matching += 1
            }
            
            return (missing, matching, extraMatches.count)
        }
        
        /// Функция, возвращающая результат проверки каждого ответа
        func checkAllAnswers(userAnswer: String, correctAnswers: [String]) -> [Bool] {
            let userKeywords = getKeywords(answer: userAnswer)
            
            return correctAnswers.map { correctAnswer in
                let answerKeywords = getKeywords(answer: correctAnswer)
                let allMatches = findAllMatches(userKeywords: userKeywords, answerKeywords: answerKeywords)
                
                let userAnswerQuality = matchQuality(matches: allMatches, correctAnswerKeywords: answerKeywords)
                
                // ПРАВИЛО: Максимальное количество пропущенных слов = 1 из 3 слов
                let maxMissingWords = Int(floor(Double(answerKeywords.count) / 3))
                if userAnswerQuality.missing > maxMissingWords {
                    return false
                }
                
                // ПРАВИЛО: Если все слова пропущены, неважно сколько напиано лишних слов = ответ неправильный
                if answerKeywords.count - userAnswerQuality.missing == 0 {
                    return false
                }
                
                // ПРАВИЛО: Максимальное количество лишних слов = 1 на 2 слова
                let maxExtraWords = Int(ceil(Double(answerKeywords.count) / 2))
                if userAnswerQuality.extra > maxExtraWords {
                    return false
                }
                
                // ПРАВИЛО: Ответ можно засчитать, если количество правильных ключевых слов плюс лишних слов, за исключением пропущенных,
                //          не больше количества ключевых слов из правильного ответа плюс максимальное количество лишних слов
                let quality = userAnswerQuality.matching + (userAnswerQuality.extra - userAnswerQuality.missing)
                
                return (answerKeywords.count...(answerKeywords.count + maxExtraWords)).contains(quality)
            }
        }
        
        return checkAllAnswers(
            userAnswer: answer,
            correctAnswers: correctAnswers
        ).contains(true)
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
                ) == .orderedSame
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
