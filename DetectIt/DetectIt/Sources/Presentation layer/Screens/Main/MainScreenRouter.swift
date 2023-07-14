import SwiftUI
import DetectItCore

@MainActor
final class MainRoutingModel: ObservableObject {
    @Published var selectedTask: Feed.Item?
    @Published var isProfileShown = false
    @Published var isCompletedTasksShown = false
    @Published var isProVersionPaywallShown = false
    @Published var isDailyTasksLimitExceededScreenShown = false
}

struct MainScreenRouter: ViewModifier {
    @ObservedObject var model: MainRoutingModel
    
    let onTaskCompleted: (_ isCompleted: Bool, _ score: Int) -> Void
    let onWatchAd: () -> Void
    
    func body(content: Content) -> some View {
        content
            .showTask($model.selectedTask, completion: onTaskCompleted)
            .fullScreenCover(isPresented: $model.isProfileShown) {
                SettingsScreen()
            }
            .sheet(isPresented: $model.isProVersionPaywallShown) {
                FullVersionPurchaseScreen()
            }
            .sheet(isPresented: $model.isDailyTasksLimitExceededScreenShown) {
                DailyLimitExceededScreen(
                    onBuyProVersion: { [unowned model] in
                        model.isProVersionPaywallShown = true
                    },
                    onWatchAd: onWatchAd
                )
                .presentationDetents([.medium])
            }
    }
}
