import SwiftUI
import Combine
import DetectItUI
import DetectItCore

struct MainScreen: View {
    
    @StateObject private var feedModel = MainFeedModel()
    @StateObject private var adsModel = MainAdsModel()
    @StateObject private var dailyTaskLimitModel = DailyTaskLimitModel()
    @StateObject private var router = MainRoutingModel()
    
    @State private var hudState: ProgressHUDState?
    @State private var isScreenDisabled = true
        
    var body: some View {
        ZStack(alignment: .top) {
            if feedModel.areAllTasksDone {
                ScreenPlaceholderViewSUI(
                    title: "main_screen_no_tasks_title".localized,
                    message: "main_screen_no_tasks_subtitle".localized
                )
            } else {
                pictureView

                taskView
            }
            
            MainScreenTopPanel(accuracy: 0) {
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
            
            await feedModel.load()
            dailyTaskLimitModel.handleDayChange()
            
            feedModel.$currentTaskIndex.publisher
                .assign(to: &adsModel.$currentTaskIndex)
            dailyTaskLimitModel.$isDailyLimitExceeded
                .assign(to: &adsModel.$isDailyTaskLimitExceeded)
            
            isScreenDisabled = false
            
            Analytics.logScreenShow(.main)
        }
        .onChange(of: feedModel.currentTask) { _ in
            adsModel.loadAds()
        }
        .onChange(of: hudState) { state in
            isScreenDisabled = state != nil
        }
        .modifier(
            MainScreenRouter(
                model: router,
                onTaskCompleted: { isCompleted, score in
                    guard isCompleted else { return }
                    _Concurrency.Task {
                        await feedModel.taskCompleted(score: score)
                        dailyTaskLimitModel.commitTaskCompletion()
                    }
                }, onWatchAd: {
                    showAd(allowFailure: false) { rewarded in
                        guard rewarded else { return }
                        
                        dailyTaskLimitModel.increaseDailyLimit(by: 1)
                        router.selectedTask = feedModel.currentTask
                    }
                }
            )
        )
    }
        
    private var pictureView: some View {
        GeometryReader { g in
            MainScreenPictureView(
                file: feedModel.currentTask?.picture,
                size: CGSize(
                    width: g.size.width,
                    height: g.size.height / 2 + g.safeAreaInsets.top
                ),
                blurred: feedModel.currentTask?.kind == .cipher,
                animationValue: feedModel.currentTask
            )
            .frame(width: g.size.width, height: g.size.height / 2)
        }
    }
    
    private var taskView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            if let task = feedModel.currentTask {
                MainScreenTaskView(
                    task: task,
                    isBlocked: dailyTaskLimitModel.isDailyLimitExceeded
                ) {
//                    _Concurrency.Task {
//                        await feedModel.changeCurrentTask(shift: 1)
                        
                        if dailyTaskLimitModel.isDailyLimitExceeded {
                            router.isDailyTasksLimitExceededScreenShown = true
                        } else if adsModel.needToShowAd {
                            showAd(allowFailure: true) { _ in
                                router.selectedTask = task
                            }
                        } else {
                            router.selectedTask = task
                        }
//                    }
                    
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
                .animation(.default, value: feedModel.currentTask)
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
                        "current_task_index": feedModel.currentTaskIndex
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
