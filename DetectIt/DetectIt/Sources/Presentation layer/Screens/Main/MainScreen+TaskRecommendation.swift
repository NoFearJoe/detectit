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
                .first { shouldRecommend(task: $0) }?
                .id
        }
        
        private func shouldRecommend(task: Feed.Item) -> Bool {
            if task.kind == .blitz, !isBlitzRecommended {
                isBlitzRecommended = true
                return true
            }
            return false
        }
        
        private var isBlitzRecommended: Bool {
            get {
                UserDefaults.standard.bool(forKey: "is_blitz_recommended")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "is_blitz_recommended")
            }
        }
        
    }
    
}
