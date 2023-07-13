import SwiftUI
import DetectItCore

extension View {
    func showTask(
        _ task: Binding<Feed.Item?>,
        completion: @escaping (Bool, Int) -> Void
    ) -> some View {
        fullScreenCover(item: task) { task in
            if let cipher = task.cipher {
                DecoderTaskScreenSUI(task: cipher, isTaskCompleted: false, onClose: completion)
            } else if let profile = task.profile {
                ProfileTaskScreenSUI(task: profile, isTaskCompleted: false, onClose: completion)
            } else if let blitz = task.blitz {
                BlitzTaskScreenSUI(task: blitz, isTaskCompleted: false, onClose: completion)
            } else if let quest = task.quest {
                QuestTaskScreenSUI(task: quest, isTaskCompleted: false, onClose: completion)
            } else {
                EmptyView()
            }
        }
    }
}
