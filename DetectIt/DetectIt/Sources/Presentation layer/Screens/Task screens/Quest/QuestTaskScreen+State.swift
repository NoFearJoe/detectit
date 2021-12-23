//
//  QuestTaskScreen+State.swift
//  DetectIt
//
//  Created by Илья Харабет on 19.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

extension QuestTaskScreen {
    
    final class State {
        
        let task: QuestTask
        let bundle: TasksBundle.Info?
        let isTaskCompleted: Bool
        
        init(task: QuestTask, bundle: TasksBundle.Info?, isTaskCompleted: Bool) {
            self.task = task
            self.bundle = bundle
            self.isTaskCompleted = isTaskCompleted
        }
        
        var isDataLoaded = false
        
        var images: [String: UIImage] = [:]
        
        var shownChapters: [QuestTask.Chapter] {
            let firstChapter = [task.chapters.first].compactMap { $0 } 
            let answeredChapters = answer?.routes.compactMap { route in task.chapters.first(where: { $0.id == route.toChapter }) } ?? []
            return firstChapter + answeredChapters
        }
        
        var currentChapter: QuestTask.Chapter? {
            guard ending == nil else { return nil }
            
            return shownChapters.last
        }
        
        var ending: QuestTask.Ending? {
            answer?.ending.flatMap { ending in task.endings.first(where: { $0.id == ending.toChapter }) }
        }
        
        lazy var answer = TaskAnswer.get(questTaskID: task.id, bundleID: bundle?.id)
        
        var score: Int? {
            guard let playerEnding = answer?.ending else { return nil }
            guard let taskEnding = task.endings.first(where: { $0.id == playerEnding.toChapter }) else { return nil }
            
            return taskEnding.score
        }
        
        var isSolved: Bool {
            score != nil
        }
        
    }
    
}
