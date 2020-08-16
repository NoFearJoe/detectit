//
//  AppInfo.swift
//  DetectItCore
//
//  Created by Илья Харабет on 16.08.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public struct AppInfo {
    
    public static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
}
