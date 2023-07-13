import SwiftUI
import DetectItUI
import DetectItCore

struct CompletedTasksScreen: View {
    private let feedService = FeedService()
    
    @State private var tasks = [Feed.Item]()
    @State private var selectedTask: Feed.Item?
    
    var body: some View {
        NavigationView {
            Group {
                if tasks.isEmpty {
                    ScreenPlaceholderViewSUI(
                        title: "completed_tasks_screen_empty_placeholder_message".localized,
                        message: nil
                    )
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(tasks, id: \.id) { task in
                                Button {
                                    selectedTask = task
                                } label: {
                                    TaskCell(
                                        kind: TaskKind(rawValue: task.kind.rawValue)?.title ?? "",
                                        title: task.title,
                                        score: task.score ?? 0,
                                        maxScore: task.maxScore
                                    )
                                }
                            }
                            
                        }
                        .padding()
                    }
                    .showTask($selectedTask, completion: { _, _ in })
                }
            }
            .navigationTitle("completed_tasks_screen_title".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Analytics.logScreenShow(.completedTasks)
        }
        .task {
            let feedItems = await feedService.obtainFeed()
            
            var tasks = [Feed.Item]()
            for item in feedItems {
                guard
                    let task = await feedService.obtainFeedItem(meta: item),
                    task.completed
                else {
                    break
                }
                
                tasks.append(task)
            }
            self.tasks = tasks
        }
    }
}

private struct TaskCell: View {
    let kind: String
    let title: String
    let score: Int
    let maxScore: Int
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(kind)
                    .font(.text5)
                    .foregroundColor(.secondaryText)
                Text(title)
                    .font(.text2)
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }
            
            Spacer(minLength: 8)
            
            Text("\(score)/\(maxScore)")
                .font(.score2)
                .foregroundColor(
                    Color(
                        uiColor: UIColor.score(
                            value: score,
                            max: maxScore
                        )
                    )
                )
        }
        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        .contentShape(Rectangle())
    }
}
