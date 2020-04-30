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
            Keychain.read("user_alias")
        }
        set {
            guard let newValue = newValue else { return }
            
            Keychain.save("user_alias", value: newValue)
        }
    }
    
    public var password: String? {
        get {
            Keychain.read("user_password")
        }
        set {
            guard let newValue = newValue else { return }
            
            Keychain.save("user_password", value: newValue)
        }
    }
    
    // TODO: Брать из апи
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
