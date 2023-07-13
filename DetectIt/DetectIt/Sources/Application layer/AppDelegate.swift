import UIKit
import Amplitude
import DetectItCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FullVersionManager.completeTransactions()
        
        handleCommandLineArguments()
        
        #if !DEBUG
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().initializeApiKey("f82ec4c4d3370dc29ba7e17dc3152d8d")
        #endif
        
        application.applicationIconBadgeNumber = 0
                
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

// MARK: - Private functions

private extension AppDelegate {
    
    func handleCommandLineArguments() {
        #if DEBUG
        if CommandLineArguments.isOnboardingPassed {
            User.shared.isOnboardingShown = true
        }
        #endif
    }
    
}
