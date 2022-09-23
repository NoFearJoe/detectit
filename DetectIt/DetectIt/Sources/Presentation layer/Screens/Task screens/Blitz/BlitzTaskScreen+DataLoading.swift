//
//  BlitzTaskScreen+DataLoading.swift
//  DetectIt
//
//  Created by Илья Харабет on 21.11.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

extension BlitzTaskScreen {
    
    func loadTask() {
        screenLoadingView.setVisible(true, animated: false)
        screenPlaceholderView.setVisible(false, animated: false)
        
        loadData(task: task) { [weak self] success in
            guard let self = self else { return }
            
            self.isDataLoaded = success
            
            self.screenView.reloadContent()
            self.updateContentState(animated: false)
            
            self.screenLoadingView.setVisible(false, animated: true)
            self.screenPlaceholderView.setVisible(!success, animated: false)
            
            if !success {
                Analytics.logScreenError(screen: .blitzTask)
            }
        }
    }
    
    func loadData(
        task: BlitzTask,
        completion: @escaping (Bool) -> Void
    ) {
        let attachmentPictures: [String] = task.attachments?.compactMap { $0.pictureName } ?? []
        let crimeDescriptionAttachmentPictures: [String] = task.crimeDescriptionAttachments?.compactMap { $0.pictureName } ?? []
        
        let allPictures = attachmentPictures + crimeDescriptionAttachmentPictures
        
        let dispatchGroup = DispatchGroup()
        
        var isDataLoaded = true
        
        var images: [String: UIImage] = [:]
        
        allPictures.forEach { picture in
            dispatchGroup.enter()
            
            ImageLoader.shared.load(
                .staticAPI(picture),
                postprocessing: { $0.applyingOldPhotoFilter() }
            ) { image, _ in
                images[picture] = image
                
                dispatchGroup.leave()
            }
        }
        
        let allAudios = task.attachments?.compactMap { $0.audioFileName } ?? []
        
        var audios: [String: Data] = [:]
        
        allAudios.forEach { audio in
            dispatchGroup.enter()
            
            AudioLoader.shared.load(path: audio) { data, _ in
                guard let data = data else { return dispatchGroup.leave()  }
                
                audios[audio] = data
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        loadScoreAndAnswer { success in
            isDataLoaded = success ? isDataLoaded : false
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.images = images
            self.audios = audios
            
            completion(isDataLoaded)
        }
    }
    
    func loadScoreAndAnswer(completion: @escaping (Bool) -> Void) {
        if let score = TaskScore.get(id: task.id, taskKind: task.kind, bundleID: bundleID),
           let answer = TaskAnswer.get(blitzTaskID: task.id, bundleID: bundleID) {
            self.score = score
            self.answer.answer = answer
            
            return completion(true)
        }
        
        guard isTaskCompleted else {
            return completion(true)
        }
        
        let dispatchGroup = DispatchGroup()
        
        var isDataLoaded = true
        
        dispatchGroup.enter()
        api.request(
            .taskScore(
                taskID: task.id,
                taskKind: task.kind.rawValue,
                bundleID: bundleID
            )
        ) { [weak self] result in
            defer { dispatchGroup.leave() }
            
            guard let self = self else { return }
            
            switch result {
            case let .success(response):
                guard let json = try? response.mapJSON() as? [String: Any], let score = json["score"] as? Int else {
                    isDataLoaded = response.statusCode == 404 ? isDataLoaded : false
                    return
                }
                
                TaskScore.set(value: score, id: self.task.id, taskKind: self.task.kind, bundleID: self.bundleID)
                self.score = score
            case .failure:
                isDataLoaded = false
            }
        }
        
        dispatchGroup.enter()
        api.request(
            .blitzAnswer(taskID: task.id)
        ) { [weak self] result in
            defer { dispatchGroup.leave() }
            
            guard let self = self else { return }
            
            switch result {
            case let .success(response):
                guard
                    let json = try? response.mapJSON() as? [String: Any],
                    let answerJSON = json["answer"],
                    let data = try? JSONSerialization.data(withJSONObject: answerJSON, options: .fragmentsAllowed),
                    let answer = try? JSONDecoder().decode(TaskAnswer.BlitzTaskAnswer.self, from: data)
                else {
                    isDataLoaded = response.statusCode == 404 ? isDataLoaded : false
                    return
                }
                
                TaskAnswer.set(answer: answer, blitzTaskID: self.task.id, bundleID: self.bundleID)
                self.answer.answer = answer
            case .failure:
                isDataLoaded = false
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(isDataLoaded)
        }
    }
    
    func saveScoreAndAnswer(_ score: Int, answer: TaskAnswer.BlitzTaskAnswer, completion: @escaping (Bool) -> Void) {
        TaskScore.set(value: score, id: task.id, taskKind: task.kind, bundleID: bundleID)
        TaskAnswer.set(answer: answer, blitzTaskID: task.id, bundleID: bundleID)
        
        let dispatchGroup = DispatchGroup()
        
        var isDataSaved = true
        
        dispatchGroup.enter()
        api.request(
            .setTaskScore(
                taskID: task.id,
                taskKind: task.kind.rawValue,
                bundleID: bundleID,
                score: score
            )
        ) { result in
            switch result {
            case .success:
                break
            case .failure:
                isDataSaved = false
            }
            dispatchGroup.leave()
        }
        
        if let answerJSON = try? JSONSerialization.jsonObject(with: try! JSONEncoder().encode(answer), options: .allowFragments) as? [String: Any] {
            dispatchGroup.enter()
            api.request(
                .setBlitzAnswer(
                    taskID: task.id,
                    answer: answerJSON
                )
            ) { result in
                switch result {
                case .success:
                    break
                case .failure:
                    isDataSaved = false
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(isDataSaved)
        }
    }
    
}
