import GameKit

public final class AuthService: ObservableObject {
    public static let shared = AuthService()
    
    @Published public var error: Error?
    @Published public var alias: String?
    @Published public var isAuthorized = false
        
    public func startAuth() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            self.error = error
            self.alias = GKLocalPlayer.local.displayName
            self.isAuthorized = GKLocalPlayer.local.isAuthenticated
        }
    }
}
