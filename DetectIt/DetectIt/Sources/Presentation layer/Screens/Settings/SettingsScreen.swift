import SwiftUI
import GameKit
import MessageUI
import DetectItUI
import DetectItCore

struct SettingsScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    @State private var isProVersionPaywallShown = false
    @State private var isCompletedTasksShown = false
    @State private var isLeaderboardPresented = false
    @State private var isSharingPresented = false
    @State private var isReportProblemPresented = false
    @State private var progressHUDState: ProgressHUDState?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("settings_screen_title".localized)
                        .font(.heading1)
                        .foregroundColor(.secondaryText)
                    Spacer()
                    closeButton
                }
                
                VSpacer(44)
                
                Group {
                    if !FullVersionManager.hasBought {
                        Group {
                            ActionButton(
                                title: "settings_screen_pro_version_action_title".localized,
                                foreground: .darkBackground,
                                background: .headlineText
                            ) {
                                isProVersionPaywallShown = true
                                
                                Analytics.logButtonTap(title: "pro_version", screen: .detectiveProfile)
                            }
                            VSpacer(8)
                        }
                    }
                    Group {
                        button(title: "settings_screen_completed_tasks_action_title".localized) {
                            isCompletedTasksShown = true
                            
                            Analytics.logButtonTap(title: "completed_tasks", screen: .detectiveProfile)
                        }
                        VSpacer(8)
                    }
                    Group {
                        button(title: "main_screen_leaderboard_action_title".localized) {
                            isLeaderboardPresented = true
                            
                            Analytics.logButtonTap(title: "rate_app", screen: .detectiveProfile)
                        }
                        VSpacer(8)
                    }
                    Group {
                        button(title: "detective_profile_rate_app_action_title".localized) {
                            openURL(AppRateManager.appStoreLink)
                            
                            Analytics.logButtonTap(title: "invite_friend", screen: .detectiveProfile)
                        }
                        VSpacer(8)
                    }
                    Group {
                        button(title: "detective_profile_invite_friend_button_title".localized) {
                            isSharingPresented = true
                            
                            Analytics.logButtonTap(title: "invite_friend", screen: .detectiveProfile)
                        }
                        VSpacer(8)
                    }
                    
                    if MFMailComposeViewController.canSendMail() {
                        button(title: "main_screen_report_problem_action_title".localized) {
                            isReportProblemPresented = true
                            
                            Analytics.logButtonTap(title: "report_problem", screen: .detectiveProfile)
                        }
                        VSpacer(8)
                    }
                    
                    button(title: "main_screen_restore_purchases_action_title".localized) {
                        progressHUDState = .loading
                        FullVersionManager.restorePurchases { success in
                            progressHUDState = success
                                ? .success
                                : .failure("error_hud_title".localized)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                progressHUDState = nil
                            }
                        }
                        
                        Analytics.logButtonTap(title: "restore_purchases", screen: .detectiveProfile)
                    }
                }
            }
            .padding()
        }
        .statusBarHidden()
        .onAppear {
            Analytics.logScreenShow(.detectiveProfile)
        }
        .sheet(isPresented: $isProVersionPaywallShown) {
            FullVersionPurchaseScreen()
        }
        .sheet(isPresented: $isCompletedTasksShown) {
            CompletedTasksScreen()
        }
        .sheet(isPresented: $isLeaderboardPresented) {
            LeaderboardScreen()
        }
        .sheet(isPresented: $isSharingPresented) {
            SharingScreen()
        }
        .sheet(isPresented: $isReportProblemPresented) {
            MailComposerScreen()
        }
        .progressHUD(state: $progressHUDState)
    }
    
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image("close", bundle: .ui)
                .resizable()
                .frame(width: 24, height: 24)
                .background(Color(uiColor: .lightGray))
                .foregroundColor(Color(uiColor: .darkGray))
                .cornerRadius(12)
        }
    }
    
    private func title(_ text: String) -> some View {
        Text(text)
            .font(.heading3)
            .foregroundColor(.secondaryText)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
    }
    
    private func score(_ text: String) -> some View {
        Text(text)
            .font(.heading1)
            .foregroundColor(.headlineText)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
    }
    
    private func button(
        title: String,
        onTap: @escaping () -> Void
    ) -> some View {
        ActionButton(
            title: title,
            foreground: .primaryText,
            background: .cardBackground,
            action: onTap
        )
    }
    
}

private struct LeaderboardScreen: UIViewControllerRepresentable {
    private let delegate = Delegate()
    
    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        GKGameCenterViewController(
            leaderboardID: "detect_leaderboard",
            playerScope: .global,
            timeScope: .allTime
        )
    }
    
    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {
        uiViewController.gameCenterDelegate = delegate
    }
    
    private final class Delegate: NSObject, GKGameCenterControllerDelegate {
        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            gameCenterViewController.dismiss(animated: true)
        }
    }
}

private struct SharingScreen: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let sharingController = UIActivityViewController(
            activityItems: [AppRateManager.appStoreLink],
            applicationActivities: nil
        )
        sharingController.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF, .saveToCameraRoll]
        
        return sharingController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct MailComposerScreen: UIViewControllerRepresentable {
    private let delegate = Delegate()
    
    private final class Delegate: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = MFMailComposeViewController()
        viewController.setPreferredSendingEmailAddress("mesterra.co@gmail.com")
        viewController.setToRecipients(["mesterra.co@gmail.com"])
        viewController.setSubject("report_problem_subject".localized)
        viewController.mailComposeDelegate = delegate
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
