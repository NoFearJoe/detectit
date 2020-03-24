//
//  TaskBundlesConsistencyTests.swift
//  DetectItCoreTests
//
//  Created by Илья Харабет on 24/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import XCTest
@testable import DetectItCore

final class TaskBundlesConsistencyTests: XCTestCase {
    
    private let taskBundles = TasksBundles.allCases

    func testThatAllTaskBundleDirectoriesIsExists() {
        taskBundles.forEach {
            guard let bundleMap = try? TasksBundleMap(bundleID: $0.rawValue) else {
                return XCTFail("The bundlemap is not exists")
            }
            
            bundleMap.audiorecords.forEach {
                XCTAssertTrue(
                    FileManager.default.fileExists(atPath: $0.path),
                    "The audiorecord is not exists at: \($0.path)"
                )
            }
            
            bundleMap.ciphers.forEach {
                XCTAssertTrue(
                    FileManager.default.fileExists(atPath: $0.path),
                    "The cipher is not exists at: \($0.path)"
                )
            }
            
            bundleMap.extraEvidences.forEach {
                XCTAssertTrue(
                    FileManager.default.fileExists(atPath: $0.path),
                    "The extra evidence is not exists at: \($0.path)"
                )
            }
            
            bundleMap.profiles.forEach {
                XCTAssertTrue(
                    FileManager.default.fileExists(atPath: $0.path),
                    "The profile is not exists at: \($0.path)"
                )
            }
            
            bundleMap.quests.forEach {
                XCTAssertTrue(
                    FileManager.default.fileExists(atPath: $0.path),
                    "The quest is not exists at: \($0.path)"
                )
            }
        }
    }
    
    func testThatTasksBundleLoadsSuccessfully() {
        taskBundles.forEach { bundle in
            guard let bundleMap = try? TasksBundleMap(bundleID: bundle.rawValue) else {
                return XCTFail("The bundlemap is not exists")
            }
            
            let exp = expectation(description: bundle.rawValue)
            
            TasksBundle.load(bundleID: bundle.rawValue) { tasksBundle in
                guard let tasksBundle = tasksBundle else {
                    return XCTFail("A tasks bundle \(bundle.rawValue) was not loaded")
                }
                
                XCTAssertTrue(
                    bundleMap.audiorecords.count == tasksBundle.audiorecordTasks.count,
                    "Audiorecords count (\(tasksBundle.audiorecordTasks.count)) is not the same with bundle map's count (\(tasksBundle.audiorecordTasks.count))"
                )
                XCTAssertTrue(
                    bundleMap.ciphers.count == tasksBundle.decoderTasks.count,
                    "Ciphers count (\(tasksBundle.decoderTasks.count)) is not the same with bundle map's count (\(bundleMap.ciphers.count))"
                )
                XCTAssertTrue(
                    bundleMap.extraEvidences.count == tasksBundle.extraEvidenceTasks.count,
                    "Extra evidences count (\(tasksBundle.extraEvidenceTasks.count)) is not the same with bundle map's count (\(tasksBundle.audiorecordTasks.count))"
                )
                XCTAssertTrue(
                    bundleMap.profiles.count == tasksBundle.profileTasks.count,
                    "Profiles count (\(tasksBundle.profileTasks.count)) is not the same with bundle map's count (\(bundleMap.profiles.count))"
                )
                XCTAssertTrue(
                    bundleMap.quests.count == tasksBundle.questTasks.count,
                    "Quests count (\(tasksBundle.questTasks.count)) is not the same with bundle map's count (\(bundleMap.quests.count))"
                )
                
                exp.fulfill()
            }
            
            waitForExpectations(timeout: 5) { error in
                XCTAssertNil(error, error?.localizedDescription ?? "The expectation produced an error")
            }
        }
    }

}
