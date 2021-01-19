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
        
        XCTAssertFalse(rightAnswer.compare(with: userAnswer))
    }
    
    func testAnswerComparision9() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "17:30", possibleAnswers: nil)
        let userAnswer = "17:30"
        
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
        
        XCTAssertFalse(rightAnswer.compare(with: userAnswer))
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
    
    /// Тест, что пользовательский ответ с лишними символами по краям строки будет засчитан
    func testAnswerComparision16() {
        let rightAnswer = DecoderTask.Answer(crimeDescription: "", decodedMessage: "test", possibleAnswers: nil)
        let userAnswer = ".test."
        
        XCTAssertTrue(rightAnswer.compare(with: userAnswer))
    }
    
}
