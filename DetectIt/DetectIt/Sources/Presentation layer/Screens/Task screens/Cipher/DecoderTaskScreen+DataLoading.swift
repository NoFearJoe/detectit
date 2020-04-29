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
    
    func loadScoreAndAnswer(completion: @escaping (Bool) -> Void) {
        if let score = TaskScore.get(id: task.id, taskKind: task.kind, bundleID: bundle?.id),
           let answer = TaskAnswer.get(decoderTaskID: task.id, bundleID: bundle?.id) {
            self.score = score
            self.answer = answer
            return completion(true)
        }
        
        let dispatchGroup = DispatchGroup()
        
        var isDataLoaded = true
        
        dispatchGroup.enter()
        api.request(
            .taskScore(
                userID: User.shared.id,
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
            .cipherAnswer(userID: User.shared.id, taskID: task.id)
        ) { [weak self] result in
            defer { dispatchGroup.leave() }
            
            guard let self = self else { return }
            
            switch result {
            case let .success(response):
                guard let json = try? response.mapJSON() as? [String: Any], let answer = json["answer"] as? String else {
                    isDataLoaded = response.statusCode == 404 ? isDataLoaded : false
                    return
                }
                
                TaskAnswer.set(answer: answer, decoderTaskID: self.task.id, bundleID: self.bundle?.id)
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
        TaskScore.set(value: score, id: task.id, taskKind: task.kind, bundleID: bundle?.id)
        TaskAnswer.set(answer: answer, decoderTaskID: task.id, bundleID: bundle?.id)
        
        let dispatchGroup = DispatchGroup()
        
        var isDataSaved = true
        
        dispatchGroup.enter()
        api.request(
            .setTaskScore(
                userID: User.shared.id,
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
        
        dispatchGroup.enter()
        api.request(
            .setCipherAnswer(
                userID: User.shared.id,
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
