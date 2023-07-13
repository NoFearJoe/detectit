//
//  TaskScoring.swift
//  DetectItCore
//
//  Created by Илья Харабет on 06/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public protocol TaskScoring {
    /// Максимальное количество очков за абсолютно верное решение задания.
    var maxScore: Int { get }
}
