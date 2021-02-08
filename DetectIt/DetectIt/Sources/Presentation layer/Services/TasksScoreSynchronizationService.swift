//
//  TasksScoreSynchronizationService.swift
//  DetectIt
//
//  Created by Илья Харабет on 08.02.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import DetectItAPI
import DetectItCore

struct TasksScoreSynchronizationService {
    
    private let api = DetectItAPI()
    
    func sync(feedItems: [Feed.Item]) {
        DispatchQueue.global().async {
            let notSyncedItemScores: [(Feed.Item, Int)] = feedItems.compactMap { item in
                guard
                    item.score == nil,
                    let localScore = TaskScore.get(
                        id: item.id,
                        taskKind: TaskKind(rawValue: item.kind.rawValue) ?? .cipher,
                        bundleID: item.bundle?.id
                    )
                else { return nil }
                
                return (item, localScore)
            }
            
            notSyncedItemScores.forEach { item, score in
                self.api.request(
                    .setTaskScore(
                        taskID: item.id,
                        taskKind: item.kind.rawValue,
                        bundleID: item.bundle?.id,
                        score: score
                    )
                ) { _ in }
            }
        }
    }
    
}
