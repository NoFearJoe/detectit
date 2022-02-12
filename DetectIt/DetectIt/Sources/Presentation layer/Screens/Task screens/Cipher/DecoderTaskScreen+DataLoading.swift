//
//  DecoderTaskScreen+DataLoading.swift
//  DetectIt
//
//  Created by Илья Харабет on 29/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import DetectItAPI
import DetectItCore

extension DecoderTaskScreen {
    
    func loadTask() {
        screenLoadingView.setVisible(true, animated: false)
        screenPlaceholderView.setVisible(false, animated: false)
        
        loadData { [weak self] success in
            guard success, self?.checkIfContentLoaded() == true else {
                self?.screenPlaceholderView.setVisible(true, animated: false)
                self?.screenLoadingView.setVisible(false, animated: true)
                self?.screenPlaceholderView.configure(
                    title: "network_error_title".localized,
                    message: "network_error_message".localized,
                    onRetry: { [unowned self] in self?.loadTask() },
                    onClose: { [unowned self] in self?.dismiss(animated: true, completion: nil) }
                )
                return
            }
            
            self?.screenLoadingView.setVisible(false, animated: true)
            self?.displayContent()
            self?.updateContentState(animated: false)
        }
    }
    
    private func loadData(completion: @escaping (Bool) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var isDataLoaded = true
        
        switch task.decodedResource {
        case .nothing:
            break
        case let .picture(path):
            dispatchGroup.enter()
            ImageLoader.shared.load(
                .staticAPI(path)
            ) { [weak self] image, _ in
                self?.encodedImage = image
                isDataLoaded = image != nil ? isDataLoaded : false
                dispatchGroup.leave()
            }
        case let .audio(path):
            dispatchGroup.enter()
            AudioLoader.shared.load(path: path) { [weak self] audio, _ in
                self?.encodedAudio = audio
                isDataLoaded = audio != nil ? isDataLoaded : false
                dispatchGroup.leave()
            }
        case let .pictureAndAudio(picturePath, audioPath):
            dispatchGroup.enter()
            ImageLoader.shared.load(
                .staticAPI(picturePath)
            ) { [weak self] image, _ in
                self?.encodedImage = image
                isDataLoaded = image != nil ? isDataLoaded : false
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            AudioLoader.shared.load(path: audioPath) { [weak self] audio, _ in
                self?.encodedAudio = audio
                isDataLoaded = audio != nil ? isDataLoaded : false
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        loadScoreAndAnswer { success in
            isDataLoaded = success ? isDataLoaded : false
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(isDataLoaded)
        }
    }
    
    private func loadScoreAndAnswer(completion: @escaping (Bool) -> Void) {
        if let score = TaskScore.get(id: task.id, taskKind: task.kind, bundleID: bundleID),
           let answer = TaskAnswer.get(decoderTaskID: task.id, bundleID: bundleID) {
            self.score = score
            self.answer = answer
            
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
            .cipherAnswer(taskID: task.id)
        ) { [weak self] result in
            defer { dispatchGroup.leave() }

            guard let self = self else { return }

            switch result {
            case let .success(response):
                guard let json = try? response.mapJSON() as? [String: Any], let answer = json["answer"] as? String else {
                    isDataLoaded = response.statusCode == 404 ? isDataLoaded : false
                    return
                }

                TaskAnswer.set(answer: answer, decoderTaskID: self.task.id, bundleID: self.bundleID)
                self.answer = answer
            case .failure:
                isDataLoaded = false
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(isDataLoaded)
        }
    }
    
    func saveScoreAndAnswer(_ score: Int, answer: String, completion: @escaping (Bool) -> Void) {
        TaskScore.set(value: score, id: task.id, taskKind: task.kind, bundleID: bundleID)
        TaskAnswer.set(answer: answer, decoderTaskID: task.id, bundleID: bundleID)
        
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
        
        dispatchGroup.enter()
        api.request(
            .setCipherAnswer(
                taskID: task.id,
                answer: answer
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
        
        dispatchGroup.notify(queue: .main) {
            completion(isDataSaved)
        }
    }
    
}
