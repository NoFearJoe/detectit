import SwiftUI
import DetectItUI
import DetectItCore

struct RootScreen: View {
    @State var isTaskPreparationShown = false
    @State var isSettingsShown = false
    
    @State var user = User.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("DETECT")
                .font(.superHeading)
                .foregroundStyle(Color.headlineText)
                .opacity(0.25)
            
            Spacer()
            
            title("detective_profile_tasks_count_title".localized)
            score("\(TaskScore.count())")
            
            VSpacer(12)
            
            title("detective_profile_total_score_title".localized)
            HStack(alignment: .firstTextBaseline) {
                score("\(user.score.total)")
                Text("из")
                    .font(.heading4)
                    .foregroundStyle(Color.secondaryText)
                score("\(user.score.max)")
            }
            
            VSpacer(12)
            
            title("detective_profile_correct_answer_percent".localized)
            score("\(Int(user.score.relative * 100))%")
            
            Spacer()
            
            button(isPrimary: true, title: "main_screen_tasks_bundle_cell_play_button_title".localized) {
                isTaskPreparationShown = true
            }
            
            button(isPrimary: false, title: "settings_screen_title".localized) {
                isSettingsShown = true
            }
        }
        .padding()
        .background {
            Color.clear.overlay {
                Image("main_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        LinearGradient(colors: [.black, .black.opacity(0)], startPoint: .bottom, endPoint: .top).ignoresSafeArea()
                    }
            }.ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
        .statusBarHidden()
        .sheet(isPresented: $isTaskPreparationShown) {
            NextTaskScreen()
                .presentationDetents([.fraction(0.66)])
                .presentationBackground(Material.ultraThin)
        }
        .sheet(isPresented: $isSettingsShown) {
            SettingsScreen()
                .presentationDetents([.fraction(0.66)])
                .presentationBackground(Material.ultraThin)
        }
    }
    
    private func title(_ text: String) -> some View {
        Text(text)
            .font(.heading3)
            .foregroundStyle(Color.secondaryText)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
    }
    
    private func score(_ text: String) -> some View {
        Text(text)
            .font(.heading0)
            .foregroundColor(.headlineText)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
    }
    
    private func button(
        isPrimary: Bool,
        title: String,
        onTap: @escaping () -> Void
    ) -> some View {
        ActionButton(
            title: title,
            foreground: isPrimary ? .black : .primaryText,
            background: isPrimary ? .yellow : .cardBackground,
            action: onTap
        )
    }
}
