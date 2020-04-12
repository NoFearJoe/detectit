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
    
    private let taskBundles = ["starter"]
    
    func testThatAllTaskBundleDirectoriesIsExists() {
        taskBundles.forEach {
            guard let bundleMap = try? TasksBundleMap(bundleID: $0) else {
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
    
    func testThatTaskBundlesLoadsSuccessfully() {
        taskBundles.forEach { bundle in
            guard let bundleMap = try? TasksBundleMap(bundleID: bundle) else {
                return XCTFail("The bundlemap is not exists")
            }
            
            let exp = expectation(description: bundle)
            
            TasksBundle.load(bundleID: bundle) { tasksBundle in
                guard let tasksBundle = tasksBundle else {
                    return XCTFail("A tasks bundle \(bundle) was not loaded")
                }
                
                XCTAssertTrue(
                    bundleMap.ciphers.count == tasksBundle.decoderTasks.count,
                    "Ciphers count (\(tasksBundle.decoderTasks.count)) is not the same with bundle map's count (\(bundleMap.ciphers.count))"
                )
                XCTAssertTrue(
                    bundleMap.extraEvidences.count == tasksBundle.extraEvidenceTasks.count,
                    "Extra evidences count (\(tasksBundle.extraEvidenceTasks.count)) is not the same with bundle map's count (\(tasksBundle.extraEvidenceTasks.count))"
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
    
    func testThatTaskBundlesContainsAllNeededResources() {
        taskBundles.forEach { bundle in
            let exp = expectation(description: bundle)
            
            TasksBundle.load(bundleID: bundle) { tasksBundle in
                guard let tasksBundle = tasksBundle else {
                    return XCTFail("A tasks bundle \(bundle) was not loaded")
                }
                
                // Проверка на то, что для всех шифров есть файлы
                tasksBundle.decoderTasks.forEach {
                    guard let url = $0.encodedPictureURL(bundleID: bundle) else {
                        return XCTFail("The encoded picture file URL is nil for file named \($0.encodedPictureName)")
                    }
                    
                    XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "The encoded picture file is not exists at \(url.path)")
                }
                
                // Проверка на то, что для всех улик есть файлы
                tasksBundle.extraEvidenceTasks.forEach { extraEvidence in
                    let extraEvidenceURLs = extraEvidence.evidencePictures.compactMap { extraEvidence.evidencePictureURL(picture: $0, bundleID: bundle) }
                    
                    XCTAssertTrue(
                        extraEvidenceURLs.count == extraEvidence.evidencePictures.count,
                        "Evidence pictures count (\(extraEvidence.evidencePictures.count)) is not equal to URLs count (\(extraEvidenceURLs.count))"
                    )
                    
                    extraEvidenceURLs.forEach { url in
                        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "The evidence picture file is not exists at \(url.path)")
                    }
                }
                
                // Проверка на то, что для всех расследований есть файлы
                tasksBundle.profileTasks.forEach { profileTask in
                    
                    // Проверка приложений к расследованию.
                    profileTask.attachments?.forEach {
                        guard let url = profileTask.attachmentURL(attachment: $0, bundleID: bundle) else {
                            switch $0.kind {
                            case .audio:
                                return XCTFail("The attachment file URL is nil for file named \($0.audioFileName!)")
                            case .picture:
                                return XCTFail("The attachment file URL is nil for file named \($0.pictureName!)")
                            }
                        }
                        
                        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "The attachment file is not exists at \(url.path)")
                    }
                    
                    // Проверка кейсов
                    profileTask.cases.forEach {
                        guard let pictureName = $0.evidencePicture?.pictureName else { return }
                        guard let url = profileTask.casePictureURL(case: $0, bundleID: bundle) else {
                            return XCTFail("The case picture file URL is nil for file named \(pictureName)")
                        }
                        
                        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "The case picture file is not exists at \(url.path)")
                    }
                    
                }
                
                exp.fulfill()
            }
            
            waitForExpectations(timeout: 10) { error in
                XCTAssertNil(error, error?.localizedDescription ?? "The expectation produced an error")
            }
        }
    }

}
