//
//  BlitzTaskScreen+State.swift
//  DetectIt
//
//  Created by Илья Харабет on 21.11.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import DetectItCore

extension BlitzTaskScreen {
    
    struct Answer {
        
        var answer: TaskAnswer.BlitzTaskAnswer?
        
        mutating func set(answer: TaskAnswer.BlitzTaskAnswer) {
            self.answer = answer
        }
        
        mutating func delete() {
            answer = nil
        }
        
        mutating func load(taskID: String, bundleID: String?) {
            answer = TaskAnswer.get(blitzTaskID: taskID, bundleID: bundleID)
        }
        
        func save(taskID: String, bundleID: String?) {
            guard let answer = answer else { return }
            TaskAnswer.set(answer: answer, blitzTaskID: taskID, bundleID: bundleID)
        }
        
    }
    
}
