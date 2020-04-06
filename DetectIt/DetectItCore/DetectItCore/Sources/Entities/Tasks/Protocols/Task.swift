//
//  Task.swift
//  DetectItCore
//
//  Created by Илья Харабет on 06/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public protocol Task {
    var id: String { get }
    var title: String { get }
    var kind: TaskKind { get }
    var taskDifficulty: TaskDifficulty { get }
}
