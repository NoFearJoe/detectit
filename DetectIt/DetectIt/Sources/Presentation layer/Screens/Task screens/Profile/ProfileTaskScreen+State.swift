//
//  ProfileTaskScreen+State.swift
//  DetectIt
//
//  Created by Илья Харабет on 09/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation
import DetectItCore

extension ProfileTaskScreen {
    
    struct Answers {
        
        var answers: [TaskAnswer.ProfileTaskAnswer] = []
        
        var count: Int {
            answers.count
        }
        
        func get(questionID: String) -> TaskAnswer.ProfileTaskAnswer? {
            answers.first(where: { $0.questionID == questionID })
        }
        
        mutating func set(answer: TaskAnswer.ProfileAnswer, questionID: String) {
            if let index = answers.firstIndex(where: { $0.questionID == questionID }) {
                answers[index] = TaskAnswer.ProfileTaskAnswer(questingID: questionID, answer: answer)
            } else {
                answers.append(TaskAnswer.ProfileTaskAnswer(questingID: questionID, answer: answer))
            }
        }
        
        mutating func delete(questionID: String) {
            answers.removeAll(where: { $0.questionID == questionID })
        }
        
        mutating func load(taskID: String, bundleID: String?) {
            answers = TaskAnswer.get(profileTaskID: taskID, bundleID: bundleID) ?? []
        }
        
        func save(taskID: String, bundleID: String?) {
            TaskAnswer.set(answers: answers, profileTaskID: taskID, bundleID: bundleID)
        }
        
    }
    
}
