import SwiftUI
import Amplitude
import DetectItCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: scene)
        self.window = window
        
        AuthService.shared.startAuth()

        if !User.shared.isOnboardingShown {
            showOnboarding()
        } else {
            showMainScreen()
        }
        
        window.makeKeyAndVisible()
        
        handleUniversalLink(options: connectionOptions)
        
        Amplitude.instance().setUserId(UIDevice.current.identifierForVendor?.uuidString ?? "")
    }
    
    private func performTransition(to screen: UIViewController) {
        guard let window = window else { return }
        
        let isRootScreen = window.rootViewController == nil
        
        window.subviews.forEach { $0.removeFromSuperview() }
        
        window.rootViewController = screen
        window.makeKeyAndVisible()
        
        guard !isRootScreen else { return }
        
        UIView.transition(
            with: window,
            duration: 1,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
    }
    
    private func showOnboarding() {
        let screen = OnboardingScreen()
        
        screen.onFinish = { [unowned self] in
            User.shared.isOnboardingShown = true
            
            self.showMainScreen()
        }
        
        performTransition(to: screen)
    }
    
    private func showMainScreen() {
        performTransition(
            to: UIHostingController(rootView: MainScreen())
        )
    }

}

// MARK: - Universal links

private extension SceneDelegate {
    
    func handleUniversalLink(options: UIScene.ConnectionOptions) {
        guard
            let userActivity = options.userActivities.first,
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true)
        else { return }

        guard
            let path = components.path,
            let params = components.queryItems
        else { return }
        
        UniversalLink.allCases.forEach { link in
            guard
                path == link.path,
                params.allSatisfy({ link.queryItems.contains($0.name) })
            else { return }
            
            print("::: Success")
        }
    }
    
    enum UniversalLink: CaseIterable {
        case task
        
        var path: String {
            return "task"
        }
        
        var queryItems: [String] {
            ["id", "kind"]
        }
    }
    
}
