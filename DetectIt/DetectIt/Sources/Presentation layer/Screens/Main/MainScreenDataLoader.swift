//
//  MainScreenDataLoader.swift
//  DetectIt
//
//  Created by Илья Харабет on 05/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

final class MainScreenDataLoader {
        
    static func getPurchaseStates(
        bundleIDs: [String]
    ) -> [String: TasksBundlePurchaseState] {
        var result: [String: TasksBundlePurchaseState] = [:]
        
        bundleIDs.forEach {
            result[$0] = PaidTaskBundlesManager.tasksBundlePurchaseState(id: $0)
        }
        
        return result
    }
    
}
