//
//  CommandLineArguments.swift
//  DetectIt
//
//  Created by Илья Харабет on 26/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

struct CommandLineArguments {
    
    static let isOnboardingPassed: Bool = {
        CommandLine.arguments.contains("onboarding_passed")
    }()
    
    static let userAlias: String? = {
        guard let index = CommandLine.arguments.firstIndex(of: "-user_alias") else { return nil }
        
        return CommandLine.arguments[index + 1]
    }()
    
    static let userPassword: String? = {
        guard let index = CommandLine.arguments.firstIndex(of: "-user_password") else { return nil }
        
        return CommandLine.arguments[index + 1]
    }()
    
}
