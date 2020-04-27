//
//  ScoreStringBuilder.swift
//  DetectItCore
//
//  Created by Илья Харабет on 26/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ScoreStringBuilder {
    
    public static func makeScoreString(score: Int?, max: Int) -> String {
        "\(score ?? 0)/\(max)"
    }
    
}
