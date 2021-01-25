//
//  DecoderTaskAnswerComparisionTests.swift
//  DetectItCoreTests
//
//  Created by Илья Харабет on 12/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import XCTest
@testable import DetectItCore

final class DecoderTaskAnswerComparisionTests: XCTestCase {
    
    func testAnswerComparision1() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Test", possibleAnswers: nil)
        let userAnswer = "test"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision2() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Test test", possibleAnswers: nil)
        let userAnswer = "test test"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision3() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Test test", possibleAnswers: nil)
        let userAnswer = " test  test "
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision4() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Test, test", possibleAnswers: nil)
        let userAnswer = "test,test"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision5() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Test, test", possibleAnswers: nil)
        let userAnswer = "test,test"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    func testAnswerComparision6() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Test, test", possibleAnswers: nil)
        let userAnswer = "test test"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision7() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Test-test", possibleAnswers: nil)
        let userAnswer = "test-test"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision8() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Test-test", possibleAnswers: nil)
        let userAnswer = "test test"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision9() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "17:30", possibleAnswers: nil)
        let userAnswer = "17:30"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ засчитается, если пользователь ввел правильное время в другом формате
    func testAnswerComparision9_1() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "17:30", possibleAnswers: nil)
        let userAnswer = "5:30 pm"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ из нескольких слов, содержащих время, засчитается, если пользователь ввел правильное время в другом формате
    func testAnswerComparision9_2() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Это было в 17:30", possibleAnswers: nil)
        let userAnswer = "Это было в 5:30 pm"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ из нескольких слов, содержащих время, засчитается, если пользователь ввел правильное время в другом формате и сделал 1 опечатку
    func testAnswerComparision9_3() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Это было в 17:30", possibleAnswers: nil)
        let userAnswer = "Эта было в 5:30 pm"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ из нескольких слов, содержащих время, НЕ засчитается, если пользователь ввел правильное время в другом формате и сделал 2 опечатки
    func testAnswerComparision9_4() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Это было в 17:30", possibleAnswers: nil)
        let userAnswer = "Эта была в 5:30 pm"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision10() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "17:30", possibleAnswers: nil)
        let userAnswer = "1730"
        
        XCTAssertFalse(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision11() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "17:30", possibleAnswers: nil)
        let userAnswer = "17 30"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision12() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "17:30", possibleAnswers: nil)
        let userAnswer = "17,30"
        
        XCTAssertFalse(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision13() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "17:30", possibleAnswers: nil)
        let userAnswer = "17 : 30"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision14() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "test, test, 17:30", possibleAnswers: nil)
        let userAnswer = "test,test,17:30"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision15() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "test, test, 17:30", possibleAnswers: nil)
        let userAnswer = "test test 17:30"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ, содержащий дату и введенный в неправильном порядке, засчитается
    func testAnswerComparision15_1() {
        XCTAssertTrue(
            ExactAnswerValidator(
                correctAnswers: ["test, test, 17:30"]
            )
            .validate(answer: "17:30 test test")
        )
    }
    
    // MARK: - Ответы с лишней информацией
    
    /// Тест, что пользовательский ответ с лишними символами по краям строки будет засчитан
    func testAnswerComparision16() {
        XCTAssertTrue(
            ExactAnswerValidator(
                correctAnswers: ["test"]
            )
            .validate(answer: ".test......")
        )
    }
    
    /// Тест, что пользовательский ответ с лишними символами по краям строки будет засчитан
    func testAnswerComparision16_1() {
        XCTAssertTrue(
            ExactAnswerValidator(
                correctAnswers: ["test, 1"]
            )
            .validate(answer: "test,, 1")
        )
    }
    
    /// Тест на то, что пользовательский ответ с неправильной последовательностью слов будет засчитан
    func testAnswerComparision17() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "test1, test2", possibleAnswers: nil)
        let userAnswer = "test2, test1"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что пользовательский ответ с неправильной последовательностью слов и отсутствующим разделителем будет засчитан
    func testAnswerComparision18() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "test1, test2", possibleAnswers: nil)
        let userAnswer = "test2 test1"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что пользовательский ответ с допустимым количеством лишних ключевых слов будет засчитан
    func testAnswerComparision19() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Сочи, стадион Фишт", possibleAnswers: nil)
        let userAnswer = "Сочи, олимпийский стадион Фишт"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что пользовательский ответ с попыткой перебора ПРАВИЛЬНЫХ вариантов будет засчитан
    func testAnswerComparision20() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Сочи, стадион Фишт", possibleAnswers: ["Адлер, стадион Фишт"])
        let userAnswer = "Сочи или Адлер, Фишт"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что пользовательский ответ с попыткой перебора вариантов, среди которых есть правильный, в котором совпадает половина и более ключевых слов, будет засчитан
    func testAnswerComparision21() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Сочи, стадион Фишт", possibleAnswers: ["Адлер, стадион Фишт"])
        let userAnswer = "Сочи или Москва, Фишт"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что пользовательский ответ с попыткой перебора вариантов, среди которых есть правильный, в котором совпадает менее половины ключевых слов, НЕ будет засчитан
    func testAnswerComparision22() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Сочи, стадион Фишт", possibleAnswers: ["Адлер, стадион Фишт"])
        let userAnswer = "Сочи или Москва или Зурбаган, Фишт"
        
        XCTAssertFalse(rightAnswer.compare(with: userAnswer))
    }
    
    // MARK: - Опечатки
    
    /// Тест на то, что ответ будет засчитан, если не совпадают буквы е-ё и и-й
    func testAnswerComparision23() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Тест", possibleAnswers: nil)
        let userAnswer = "Тёст"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ будет засчитан, если в нем допущено не более 1 опечаток
    func testAnswerComparision24() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Аэропорт", possibleAnswers: nil)
        let userAnswer = "Пэропорт"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ НЕ будет засчитан, если в нем допущено более 1 опечатки
    func testAnswerComparision25() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Аэропорт", possibleAnswers: nil)
        let userAnswer = "Пэропорд"
        
        XCTAssertFalse(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ из нескольких слов с одной опечаткой будет засчитан
    func testAnswerComparision26() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "Аэропорт Хартсхилд-Джексон", possibleAnswers: nil)
        let userAnswer = "Пэропорт Хартсхилд-Джексон"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ будет засчитан, если пользователь разделил все буквы пробелом
    func testAnswerComparision26_4() {
        XCTAssertTrue(
            ExactAnswerValidator(
                correctAnswers: ["test"]
            ).validate(answer: "t e s t")
        )
    }
    
    /// Тест на то, что ответ НЕ будет засчитан, если пользователь ввел ответ задом-наперед
    func testAnswerComparision26_5() {
        XCTAssertFalse(
            ExactAnswerValidator(
                correctAnswers: ["test"]
            ).validate(answer: "tset")
        )
    }
    
    // MARK: - Даты
    
    /// Тест на то, что ответ, содержащий дату будет засчитан, если дата написана в другом формате
    func testAnswerComparision27() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "15.02.1994", possibleAnswers: nil)
        let userAnswer = "15.2.1994"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ, содержащий дату будет засчитан, если дата написана в другом формате
    func testAnswerComparision28() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "15.02.1994", possibleAnswers: nil)
        let userAnswer = "02.15.1994"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ, содержащий дату будет засчитан, если дата написана в другом формате
    func testAnswerComparision29() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "15.02.1994", possibleAnswers: nil)
        let userAnswer = "2.15.1994"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ, содержащий дату НЕ будет засчитан, если год написан сокращенно
    func testAnswerComparision30() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "15.02.1994", possibleAnswers: nil)
        let userAnswer = "15.02.94"
        
        XCTAssertFalse(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ, содержащий дату и время будет засчитан, если ответ полностью введен верно
    func testAnswerComparision30_1() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "15.02.1994 17:30", possibleAnswers: nil)
        let userAnswer = "15.02.1994 17:30"
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
    /// Тест на то, что ответ, состоящий из нескольких слов с несколькими ошибками (больше нормы) НЕ будет засчитан
    func testAnswerComparision31_1() {
        XCTAssertFalse(
            ExactAnswerValidator(
                correctAnswers: ["Shakespeare is F. Bacon"]
            ).validate(answer: "Shakespire is j Bacon")
        )
    }
    
    /// Тест на то, что ответ, состоящий из нескольких слов с несколькими ошибками (в пределах нормы) будет засчитан
    func testAnswerComparision31_2() {
        XCTAssertTrue(
            ExactAnswerValidator(
                correctAnswers: ["Shakespeare is F. Bacon"]
            ).validate(answer: "Shakespiare is j Bacon")
        )
    }
    
    // MARK: - Повторения
    
    /// Тест на то, что ответ не будет засчитан, если в правильном ответе есть повторяющиеся слова, но пользователь не ввел их все
    func testAnswerComparision32_1() {
        XCTAssertFalse(
            ExactAnswerValidator(
                correctAnswers: ["test test test"]
            ).validate(answer: "test")
        )
    }
    
    /// Тест на то, что ответ не будет засчитан, если в правильном ответе есть повторяющиеся символы, но пользователь ввел только 1
    func testAnswerComparision32_2() {
        XCTAssertFalse(
            ExactAnswerValidator(
                correctAnswers: ["111"]
            ).validate(answer: "1")
        )
    }
    
    /// Тест на то, что ответ не будет засчитан, если в правильном ответе есть повторяющиеся символы, но пользователь ввел только 1
    func testAnswerComparision32_3() {
        XCTAssertFalse(
            ExactAnswerValidator(
                correctAnswers: ["aaa"]
            ).validate(answer: "a")
        )
    }
    
    /// Тест на то, что ответ не будет засчитан, если в правильном ответе есть повторяющиеся символы, но пользователь ввел только 1
    func testAnswerComparision32_4() {
        XCTAssertFalse(
            ExactAnswerValidator(
                correctAnswers: ["aaa"]
            ).validate(answer: "aa")
        )
    }
    
    /// Тест на то, что ответ из одного слова будет засчитан, если пользователь ввел ответ 2 раза
    func testAnswerComparision32_5() {
        XCTAssertTrue(
            ExactAnswerValidator(
                correctAnswers: ["test"]
            ).validate(answer: "test test")
        )
    }
    
    /// Тест на то, что ответ из одного слова НЕ будет засчитан, если пользователь ввел ответ 3 раза
    func testAnswerComparision32_6() {
        XCTAssertFalse(
            ExactAnswerValidator(
                correctAnswers: ["test"]
            ).validate(answer: "test test test")
        )
    }
    
    // MARK: - Проверка зачета нескольких вариантов ответа
    
    /// Тест на то, что ответ будет засчитан, если пользователь ввел альтернативный вариант ответа
    func testAnswerComparision33_1() {
        XCTAssertTrue(
            ExactAnswerValidator(
                correctAnswers: ["test", "foo"]
            ).validate(answer: "foo")
        )
    }
    
    /// Тест на то, что ответ будет засчитан, если пользователь ввел основной и альтернативный вариант ответа
    func testAnswerComparision33_2() {
        XCTAssertTrue(
            ExactAnswerValidator(
                correctAnswers: ["test", "foo"]
            ).validate(answer: "test foo")
        )
    }
    
    /// Тест на то, что ответ НЕ будет засчитан, если пользователь ввел основной и альтернативный вариант ответа одним словом
    func testAnswerComparision33_3() {
        XCTAssertFalse(
            ExactAnswerValidator(
                correctAnswers: ["test", "foo"]
            ).validate(answer: "testfoo")
        )
    }
    
}
