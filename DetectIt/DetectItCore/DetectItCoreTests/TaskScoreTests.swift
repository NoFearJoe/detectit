//
//  TaskScoreTests.swift
//  DetectItCoreTests
//
//  Created by Илья Харабет on 05/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import XCTest
@testable import DetectItCore

final class TaskScoreTests: XCTestCase {
    
    override class func tearDown() {
        super.tearDown()
        
        TaskScore.clear()
    }
    
    func testThatAudioRecordScoreStoresCorrectly() {
        let score = Float(0.5)
        let id = "test_audio_record"
        
        TaskScore.set(score: score, audioRecordTaskID: id)
        
        let savedScore = TaskScore.get(audioRecordTaskID: id)
        XCTAssertEqual(score, savedScore)
    }
    
    func testThatExtraEvidenceScoreStoresCorrectly() {
        let score = true
        let id = "test_extra_evidence"
        
        TaskScore.set(score: score, extraEvidenceTaskID: id)
        
        let savedScore = TaskScore.get(extraEvidenceTaskID: id)
        XCTAssertEqual(score, savedScore)
    }
    
    func testThatCipherScoreStoresCorrectly() {
        let score = true
        let id = "test_cipher"
        
        TaskScore.set(score: score, decoderTaskID: id)
        
        let savedScore = TaskScore.get(decoderTaskID: id)
        XCTAssertEqual(score, savedScore)
    }
    
    func testThatProfileScoreStoresCorrectly() {
        let score = Float(0.95)
        let id = "test_profile"
        
        TaskScore.set(score: score, profileTaskID: id)
        
        let savedScore = TaskScore.get(profileTaskID: id)
        XCTAssertEqual(score, savedScore)
    }
    
    func testThatQuestScoreStoresCorrectly() {
        let score = Float(0.25)
        let id = "test_quest"
        
        TaskScore.set(score: score, questTaskID: id)
        
        let savedScore = TaskScore.get(questTaskID: id)
        XCTAssertEqual(score, savedScore)
    }
    
}
