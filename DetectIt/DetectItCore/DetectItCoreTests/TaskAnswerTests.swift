//
//  TaskAnswerTests.swift
//  DetectItCoreTests
//
//  Created by Илья Харабет on 05/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import XCTest
@testable import DetectItCore

final class TaskAnswerTests: XCTestCase {
    
    override class func tearDown() {
        super.tearDown()
        
        TaskAnswer.clear()
    }
    
    func testThatExtraEvidenceAnswerStoresCorrectly() {
        let id = "test_extra_evidence"
        let answer = "picture_1"
        
        TaskAnswer.set(answer: answer, extraEvidenceTaskID: id)
        
        let savedAnswer = TaskAnswer.get(extraEvidenceTaskID: id)
        XCTAssertEqual(answer, savedAnswer)
    }
    
    func testThatCipherAnswerStoresCorrectly() {
        let id = "test_cipher"
        let answer = "decoded_message"
        
        TaskAnswer.set(answer: answer, decoderTaskID: id)
        
        let savedAnswer = TaskAnswer.get(decoderTaskID: id)
        XCTAssertEqual(answer, savedAnswer)
    }
    
    func testThatProfileAnswerStoresCorrectly() {
        let id = "test_profile"
        let answers = [
            TaskAnswer.ProfileTaskAnswer(questingID: "q1", answer: .string("a1")),
            TaskAnswer.ProfileTaskAnswer(questingID: "q2", answer: .int(1)),
            TaskAnswer.ProfileTaskAnswer(questingID: "q3", answer: .bool(true))
        ]
        
        TaskAnswer.set(answers: answers, profileTaskID: id)
        
        guard let savedAnswers = TaskAnswer.get(profileTaskID: id) else {
            return XCTFail()
        }
        
        zip(answers, savedAnswers).forEach {
            XCTAssertEqual($0.questionID, $0.questionID)
            XCTAssertEqual($0.answer, $1.answer)
        }
    }
    
    func testThatQuestAnswerStoresCorrectly() {
        let id = "test_quest"
        let answer = TaskAnswer.QuestTaskAnswer(chapterIDs: ["chap1", "chap2"], endingID: "end1")
        
        TaskAnswer.set(answer: answer, questTaskID: id)
        
        let savedAnswer = TaskAnswer.get(questTaskID: id)
        XCTAssertEqual(answer.chapterIDs, savedAnswer?.chapterIDs)
        XCTAssertEqual(answer.endingID, savedAnswer?.endingID)
    }

}

extension TaskAnswer.ProfileAnswer: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.string(s1), .string(s2)):
            return s1 == s2
        case let (.int(i1), .int(i2)):
            return i1 == i2
        case let (.bool(b1), .bool(b2)):
            return b1 == b2
        default:
            return false
        }
    }
    
}
