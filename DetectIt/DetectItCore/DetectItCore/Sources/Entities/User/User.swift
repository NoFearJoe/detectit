import SwiftUI

@Observable
public final class User {
    
    public static let shared = User()
    
    #if RELEASE
    private let storage: Storage = Keychain()
    #else
    private let storage: Storage = UserDefaults.standard
    #endif
    
    public struct Score: Codable {
        public let total: Int
        public let max: Int
        
        static let zero = Score(total: 0, max: 0)
        
        public var relative: Double {
            if max == 0 {
                return 0
            } else {
                return Double(total) / Double(max)
            }
        }
        
        public func increased(total: Int, max: Int) -> Score {
            Score(total: self.total + total, max: self.max + max)
        }
    }
    
    private var scoreKey: String { "user_score" }
    public var score: Score {
        get {
            access(keyPath: \.score)
            return storage.getDecodable(key: scoreKey) ?? .zero
        }
        set {
            withMutation(keyPath: \.score) {
                storage.saveEncodable(newValue, key: scoreKey)
            }
        }
    }
    
    public var isDecoderHelpShown: Bool {
        get {
            access(keyPath: \.isDecoderHelpShown)
            return UserDefaults.standard.bool(forKey: "is_decoder_help_shown")
        }
        set {
            withMutation(keyPath: \.isDecoderHelpShown) {
                UserDefaults.standard.set(newValue, forKey: "is_decoder_help_shown")
            }
        }
    }
    
    public var isProfileHelpShown: Bool {
        get {
            access(keyPath: \.isProfileHelpShown)
            return UserDefaults.standard.bool(forKey: "is_profile_help_shown")
        }
        set {
            withMutation(keyPath: \.isProfileHelpShown) {
                UserDefaults.standard.set(newValue, forKey: "is_profile_help_shown")
            }
        }
    }
    
    public var isQuestHelpShown: Bool {
        get {
            access(keyPath: \.isQuestHelpShown)
            return UserDefaults.standard.bool(forKey: "is_quest_help_shown")
        }
        set {
            withMutation(keyPath: \.isQuestHelpShown) {
                UserDefaults.standard.set(newValue, forKey: "is_quest_help_shown")
            }
        }
    }
    
    public var isOnboardingShown: Bool {
        get {
            access(keyPath: \.isOnboardingShown)
            return UserDefaults.standard.bool(forKey: "is_onboarding_shown")
        }
        set {
            withMutation(keyPath: \.isOnboardingShown) {
                UserDefaults.standard.set(newValue, forKey: "is_onboarding_shown")
            }
        }
    }
}
