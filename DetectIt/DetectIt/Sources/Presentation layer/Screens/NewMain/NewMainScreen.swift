import SwiftUI
import DetectItUI
import DetectItCore

// TODO: Улучшить экраны обучения? Добавить картинки?
// TODO: Добавить картинки в задания где их нет
// TODO: СДелать эффект плавающей картинки при наклоне телефона

struct NewMainScreen: View {
    
    @StateObject private var model = NewMainModel()
    @StateObject private var adsModel = MainAdsModel()
    @StateObject private var dailyTaskLimitModel = DailyTaskLimitModel()
    @StateObject private var router = NewMainRoutingModel()
    
    @State private var hudState: ProgressHUDState?
    @State private var isScreenDisabled = true
    
    var body: some View {
        ZStack(alignment: .top) {
            if model.areAllTasksDone {
                ScreenPlaceholderViewSUI(
                    title: "main_screen_no_tasks_title".localized,
                    message: "main_screen_no_tasks_subtitle".localized
                )
            } else {
                pictureView

                taskView
            }
            
            NewProfileView(accuracy: 0) {
                router.isProfileShown = true
//                model.changeCurrentTask(shift: -1)
            }
            .padding()
        }
        .disabled(isScreenDisabled)
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .statusBarHidden()
        .accessibilityIdentifier("main_screen")
        .accessibilityElement(children: .contain)
        .progressHUD(state: $hudState)
        .singleTask {
//            dailyTaskLimitModel.testStarted()
            
            await model.load()
            dailyTaskLimitModel.handleDayChange()
            
            adsModel.currentTaskIndex = model.currentTaskIndex
            adsModel.isDailyTaskLimitExceeded = dailyTaskLimitModel.isDailyLimitExceeded
            
            isScreenDisabled = false
            
            Analytics.logScreenShow(.main)
        }
        .onChange(of: model.currentTaskIndex) {
            adsModel.currentTaskIndex = $0
        }
        .onChange(of: dailyTaskLimitModel.isDailyLimitExceeded) {
            adsModel.isDailyTaskLimitExceeded = $0
        }
        .onChange(of: model.currentTask) { _ in
            adsModel.loadAds()
        }
        .onChange(of: hudState) { state in
            isScreenDisabled = state != nil
        }
        .showTask($router.selectedTask) { isCompleted, score in
            guard isCompleted else { return }
            SwiftUI.Task {
                await model.taskCompleted(score: score)
                dailyTaskLimitModel.commitTaskCompletion()
            }
        }
        .fullScreenCover(isPresented: $router.isProfileShown) {
            SettingsScreen()
        }
        .sheet(isPresented: $router.isProVersionPaywallShown) {
            FullVersionPurchaseScreen()
        }
        .sheet(isPresented: $router.isDailyTasksLimitExceededScreenShown) {
            DailyLimitExceededScreen(
                onBuyProVersion: {
                    router.isProVersionPaywallShown = true
                },
                onWatchAd: {
                    showAd(allowFailure: false) { rewarded in
                        guard rewarded else { return }
                        
                        dailyTaskLimitModel.increaseDailyLimit(by: 1)
                        router.selectedTask = model.currentTask
                    }
                }
            )
            .presentationDetents([.medium])
        }
    }
        
    private var pictureView: some View {
        GeometryReader { g in
            MainScreenPictureView(
                file: model.currentTask?.picture,
                size: CGSize(
                    width: g.size.width,
                    height: g.size.height / 2 + g.safeAreaInsets.top
                ),
                blurred: model.currentTask?.kind == .cipher
            )
            .frame(width: g.size.width, height: g.size.height / 2)
            .animation(.default, value: model.currentTask)
        }
    }
    
    private var taskView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            if let task = model.currentTask {
                NewTaskCell(
                    task: task,
                    isBlocked: dailyTaskLimitModel.isDailyLimitExceeded
                ) {
//                    model.changeCurrentTask(shift: 1)
                    
                    if dailyTaskLimitModel.isDailyLimitExceeded {
                        router.isDailyTasksLimitExceededScreenShown = true
                    } else if adsModel.needToShowAd {
                        showAd(allowFailure: true) { _ in
                            router.selectedTask = task
                        }
                    } else {
                        router.selectedTask = task
                    }
                    
                    Analytics.log(
                        "task_selected",
                        parameters: [
                            "id": task.id,
                            "kind": task.kind.rawValue,
                            "difficulty": task.difficulty,
                            "score": task.score ?? 0,
                            "screen": Analytics.Screen.main.rawValue
                        ]
                    )
                }
                .animation(.default, value: model.currentTask)
            }
        }
        .padding()
        .layoutPriority(1)
    }
    
    private func showAd(
        allowFailure: Bool,
        completion: @escaping (_ rewarded: Bool) -> Void
    ) {
        adsModel.present(allowFailure: allowFailure) { state in
            switch state {
            case .loading:
                hudState = .loading
            case .presented:
                hudState = nil
                
                Analytics.logScreenShow(
                    .ad,
                    parameters: [
                        "current_task_index": model.currentTaskIndex
                    ]
                )
            case let .completed(rewarded):
                completion(rewarded)
            case .failed:
                hudState = .failure("hud_failed_to_load_ad_message".localized)
                
                Analytics.log("present_ad_failed")
            }
        }
    }
}
