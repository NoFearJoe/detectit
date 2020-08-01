//
//  QuestTaskScreen+DataLoading.swift
//  DetectIt
//
//  Created by Илья Харабет on 19.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

extension QuestTaskScreen {
    
    func loadTask() {
        screenLoadingView.setVisible(true, animated: false)
        screenPlaceholderView.setVisible(false, animated: false)
        
        loadData(task: state.task) { [weak self] success in
            guard let self = self else { return }
            
            self.state.isDataLoaded = success
            
            self.updateContentState(animated: false)
            
            self.screenLoadingView.setVisible(false, animated: true)
            self.screenPlaceholderView.setVisible(!success, animated: false)
        }
    }
    
    func loadData(
        task: QuestTask,
        completion: @escaping (Bool) -> Void
    ) {
        loadAnswer { success in
            completion(success)
        }
    }
    
    func loadAnswer(completion: @escaping (Bool) -> Void) {
        if let answer = TaskAnswer.get(questTaskID: state.task.id, bundleID: state.bundle?.id) {
            state.answer = answer
            return completion(true)
        }
        
        let dispatchGroup = DispatchGroup()
        
        var isDataLoaded = true
        
        dispatchGroup.enter()
        api.request(
            .questAnswer(taskID: state.task.id)
        ) { [weak self] result in
            defer { dispatchGroup.leave() }
            
            guard let self = self else { return }
            
            switch result {
            case let .success(response):
                guard
                    let json = try? response.mapJSON() as? [String: Any],
                    let answerJSON = json["answer"],
                    let data = try? JSONSerialization.data(withJSONObject: answerJSON, options: .fragmentsAllowed),
                    let answer = try? JSONDecoder().decode(TaskAnswer.QuestTaskAnswer.self, from: data)
                else {
                    isDataLoaded = response.statusCode == 404 ? isDataLoaded : false
                    return
                }
                
                TaskAnswer.set(answer: answer, questTaskID: self.state.task.id, bundleID: self.state.bundle?.id)
                self.state.answer = answer
            case .failure:
                isDataLoaded = false
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(isDataLoaded)
        }
    }
    
    func saveScoreAndAnswer(score: Int, answer: TaskAnswer.QuestTaskAnswer, completion: @escaping (Bool) -> Void) {
        TaskScore.set(value: score, id: state.task.id, taskKind: state.task.kind, bundleID: state.bundle?.id)
        TaskAnswer.set(answer: answer, questTaskID: state.task.id, bundleID: state.bundle?.id)
        
        let dispatchGroup = DispatchGroup()
        
        var isDataSaved = true
        
        dispatchGroup.enter()
        api.request(
            .setTaskScore(
                taskID: state.task.id,
                taskKind: state.task.kind.rawValue,
                bundleID: state.bundle?.id,
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
        
        if let answersJSON = try? JSONSerialization.jsonObject(with: try! JSONEncoder().encode(answer), options: .allowFragments) as? [String: Any] {
            dispatchGroup.enter()
            api.request(
                .setQuestAnswer(
                    taskID: state.task.id,
                    answer: answersJSON
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
