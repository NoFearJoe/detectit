import SwiftUI
import Combine
import GameKit
import DetectItCore

@MainActor
final class MainFeedModel: NSObject, ObservableObject {
    @Published private(set) var currentTask: Feed.Item?
    @Published private(set) var areAllTasksDone = false
    
    @Published private var leaderboard: GKLeaderboard?
    
    @MainActor private var feedItems: [FeedItem] = []
    
    @PublishedAppStorage("current_task_index")
    private(set) var currentTaskIndex = 0
        
    private let feedService = FeedService()
        
    func load() async {
        feedItems = await feedService.obtainFeed()
        currentTask = await loadCurrentTask()
        
        _Concurrency.Task {
            do {
                leaderboard = try await GKLeaderboard
                    .loadLeaderboards(IDs: ["detect_leaderboard"])
                    .first
            } catch {
                print(":::", error)
            }
        }
    }
    
    // For testing
    func changeCurrentTask(shift: Int) async {
        currentTaskIndex += shift
        currentTask = await loadCurrentTask()
    }
    
    func taskCompleted(score: Int) async {
        User.shared.score = User.shared.score.increased(
            total: score,
            max: currentTask?.maxScore ?? score
        )
        
        currentTaskIndex += 1
        currentTask = await loadCurrentTask()
        
        #if !DEBUG
        _Concurrency.Task {
            do {
                try await leaderboard?.submitScore(
                    score,
                    context: 0,
                    player: GKLocalPlayer.local
                )
            } catch {
                print(":::", error)
            }
        }
        #endif
    }
    
    private func loadCurrentTask() async -> Feed.Item? {
        guard currentTaskIndex < feedItems.count else {
            areAllTasksDone = true
            return nil
        }
        
        if currentTaskIndex < 0 {
            currentTaskIndex = 0
        }
    
        func getUncompletedTask(index: Int) async -> Feed.Item? {
            let item = feedItems[index]
            let task = await feedService.obtainFeedItem(meta: item)
            
            if task?.completed == true {
                return await getUncompletedTask(index: index + 1)
            } else {
                if currentTaskIndex != index {
                    currentTaskIndex = index
                }
                return task
            }
        }
        
        return await getUncompletedTask(index: currentTaskIndex)
    }
}
