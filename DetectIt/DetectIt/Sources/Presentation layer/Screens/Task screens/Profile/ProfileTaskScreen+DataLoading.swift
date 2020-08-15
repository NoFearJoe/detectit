//
//  ProfileTaskScreen+DataLoading.swift
//  DetectIt
//
//  Created by Илья Харабет on 09/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

extension ProfileTaskScreen {
    
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
        }
    }
    
    func loadData(
        task: ProfileTask,
        completion: @escaping (Bool) -> Void
    ) {
        let casePictures: [String] = task.cases.compactMap { $0.evidencePicture?.pictureName }
        
        let attachmentPictures: [String] = task.attachments?.compactMap { $0.pictureName } ?? []
        
        let allPictures = casePictures + attachmentPictures
        
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
        if let score = TaskScore.get(id: task.id, taskKind: task.kind, bundleID: bundle?.id),
           let answers = TaskAnswer.get(profileTaskID: task.id, bundleID: bundle?.id) {
            self.score = score
            self.answers.answers = answers
            return completion(true)
        }
        
        let dispatchGroup = DispatchGroup()
        
        var isDataLoaded = true
        
        dispatchGroup.enter()
        api.request(
            .taskScore(
                taskID: task.id,
                taskKind: task.kind.rawValue,
                bundleID: bundle?.id
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
                
                TaskScore.set(value: score, id: self.task.id, taskKind: self.task.kind, bundleID: self.bundle?.id)
                self.score = score
            case .failure:
                isDataLoaded = false
            }
        }
        
        dispatchGroup.enter()
        api.request(
            .profileAnswers(taskID: task.id)
        ) { [weak self] result in
            defer { dispatchGroup.leave() }
            
            guard let self = self else { return }
            
            switch result {
            case let .success(response):
                guard
                    let json = try? response.mapJSON() as? [String: Any],
                    let answersJSON = json["answers"],
                    let data = try? JSONSerialization.data(withJSONObject: answersJSON, options: .fragmentsAllowed),
                    let answers = try? JSONDecoder().decode([TaskAnswer.ProfileTaskAnswer].self, from: data)
                else {
                    isDataLoaded = response.statusCode == 404 ? isDataLoaded : false
                    return
                }
                
                TaskAnswer.set(answers: answers, profileTaskID: self.task.id, bundleID: self.bundle?.id)
                self.answers.answers = answers
            case .failure:
                isDataLoaded = false
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(isDataLoaded)
        }
    }
    
    func saveScoreAndAnswer(_ score: Int, answers: [TaskAnswer.ProfileTaskAnswer], completion: @escaping (Bool) -> Void) {
        TaskScore.set(value: score, id: task.id, taskKind: task.kind, bundleID: bundle?.id)
        TaskAnswer.set(answers: answers, profileTaskID: task.id, bundleID: bundle?.id)
        
        let dispatchGroup = DispatchGroup()
        
        var isDataSaved = true
        
        dispatchGroup.enter()
        api.request(
            .setTaskScore(
                taskID: task.id,
                taskKind: task.kind.rawValue,
                bundleID: bundle?.id,
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
        
        if let answersJSON = try? JSONSerialization.jsonObject(with: try! JSONEncoder().encode(answers), options: .allowFragments) as? [[String: Any]] {
            dispatchGroup.enter()
            api.request(
                .setProfileAnswers(
                    taskID: task.id,
                    answers: answersJSON
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
