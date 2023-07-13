import SwiftUI
import DetectItUI
import DetectItCore

struct NewTaskCell: View {
    let task: Feed.Item
    let isBlocked: Bool
    let onTap: () -> Void
        
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            taskKindView
            
            VSpacer(8)
            
            difficultyView
            
            VSpacer(8)
            
            titleView
                            
            descriptionView
            
            VSpacer(20)
            
            ActionButton(
                icon: isBlocked ? Image(systemName: "lock.fill") : nil,
                title: "main_screen_play_button_title".localized,
                foreground: .darkBackground,
                background: .headlineText,
                action: onTap
            )
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private var taskKindView: some View {
        Text(TaskKind(rawValue: task.kind.rawValue)!.title)
            .font(.heading4)
            .foregroundColor(.secondaryText)
            .lineLimit(1)
    }
    
    private var difficultyView: some View {
        HStack {
            Text("main_screen_task_difficulty_title".localized)
                .font(.score3)
                .foregroundColor(.primaryText)
            
            // TODO: Починить анимацию смены задания
            Text(TaskDifficulty(rawValue: task.difficulty).localizedTitle)
                .font(.score3)
                .foregroundColor(Color(uiColor: TaskDifficulty(rawValue: task.difficulty).color))
            
            Image(uiImage: TaskDifficulty(rawValue: task.difficulty).icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 16)
                .foregroundColor(.headlineText)
            
            Spacer()
        }
    }
    
    private var titleView: some View {
        Text(task.title)
            .font(.heading1)
            .foregroundColor(.primaryText)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
    }
    
    @ViewBuilder
    private var descriptionView: some View {
        if let subtitle = task.subtitle, !subtitle.isEmpty {
            VSpacer(8)
            
            Text(subtitle)
                .font(.text3)
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.leading)
                .lineLimit(5)
        }
    }
}
