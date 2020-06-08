//
//  User.swift
//  DetectItCore
//
//  Created by Илья Харабет on 14/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public final class User {
    
    public static let shared = User()
    
    public var isAuthorized: Bool {
        alias != nil && password != nil
    }
    
    public var alias: String? {
        get {
            UserDefaults.standard.object(forKey: "user_alias") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "user_alias")
        }
    }
    
    public var email: String? {
        get {
            UserDefaults.standard.object(forKey: "user_email") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "user_email")
        }
    }
    
    public var password: String? {
        get {
            UserDefaults.standard.object(forKey: "user_password") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "user_password")
        }
    }
    
    public var rank: UserRank {
        UserRank(score: totalScore)
    }
    
    private var totalScoreKey: String { "\(alias ?? "")_total_score" }
    public var totalScore: Int {
        get {
            UserDefaults.standard.integer(forKey: totalScoreKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: totalScoreKey)
        }
    }
    
    public var isDecoderHelpShown: Bool {
        get {
            UserDefaults.standard.bool(forKey: "is_decoder_help_shown")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "is_decoder_help_shown")
        }
    }
    
    public var isProfileHelpShown: Bool {
        get {
            UserDefaults.standard.bool(forKey: "is_profile_help_shown")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "is_profile_help_shown")
        }
    }
    
    public var isOnboardingShown: Bool {
        get {
            UserDefaults.standard.bool(forKey: "is_onboarding_shown")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "is_onboarding_shown")
        }
    }
    
}
