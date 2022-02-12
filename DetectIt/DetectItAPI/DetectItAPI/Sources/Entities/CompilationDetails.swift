//
//  CompilationDetails.swift
//  DetectItCore
//
//  Created by Илья Харабет on 30.01.2022.
//  Copyright © 2022 Mesterra. All rights reserved.
//

import Foundation

public struct CompilationDetails: Codable {
    public let compilation: Feed.Compilation
    public let tasks: [Feed.Item]
}
