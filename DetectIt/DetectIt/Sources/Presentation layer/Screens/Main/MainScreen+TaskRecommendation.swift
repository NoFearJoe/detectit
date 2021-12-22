//
//  MainScreen+TaskRecommendation.swift
//  DetectIt
//
//  Created by Илья Харабет on 22.12.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import DetectItAPI

extension MainScreen {
    
    final class TaskRecommender {
        
        var recommendedTaskID: String?
        
        func updateRecommendation(tasks: [Feed.Item]) {
            recommendedTaskID = tasks
                .first { shouldRecommend(task: $0, allTasks: tasks) }?
                .id
        }
        
        private func shouldRecommend(task: Feed.Item, allTasks: [Feed.Item]) -> Bool {
            task.kind == .blitz && !task.completed && !allTasks.contains(where: { $0.kind == .blitz && task.completed })
        }
        
    }
    
}
