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
        let score = 1
        let id = "test_audio_record"
        
        TaskScore.set(value: score, id: id, taskKind: .audiorecord, bundleID: "test")
        
        let savedScore = TaskScore.get(id: id, taskKind: .audiorecord, bundleID: "test")
        XCTAssertEqual(score, savedScore)
    }
    
    func testThatExtraEvidenceScoreStoresCorrectly() {
        let score = 2
        let id = "test_extra_evidence"
        
        TaskScore.set(value: score, id: id, taskKind: .extraEvidence, bundleID: "test")
        
        let savedScore = TaskScore.get(id: id, taskKind: .extraEvidence, bundleID: "test")
        XCTAssertEqual(score, savedScore)
    }
    
    func testThatCipherScoreStoresCorrectly() {
        let score = 3
        let id = "test_cipher"
        
        TaskScore.set(value: score, id: id, taskKind: .cipher, bundleID: "test")
        
        let savedScore = TaskScore.get(id: id, taskKind: .cipher, bundleID: "test")
        XCTAssertEqual(score, savedScore)
    }
    
    func testThatProfileScoreStoresCorrectly() {
        let score = 4
        let id = "test_profile"
        
        TaskScore.set(value: score, id: id, taskKind: .profile, bundleID: "test")
        
        let savedScore = TaskScore.get(id: id, taskKind: .profile, bundleID: "test")
        XCTAssertEqual(score, savedScore)
    }
    
    func testThatQuestScoreStoresCorrectly() {
        let score = 5
        let id = "test_quest"
        
        TaskScore.set(value: score, id: id, taskKind: .quest, bundleID: "test")
        
        let savedScore = TaskScore.get(id: id, taskKind: .quest, bundleID: "test")
        XCTAssertEqual(score, savedScore)
    }
    
}
