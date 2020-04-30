//
//  DetectItAPI.swift
//  DetectItAPI
//
//  Created by Илья Харабет on 26/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Moya
import DetectItCore

public final class DetectItAPI: MoyaProvider<DetectItAPITarget> {
    
    public init() {
        super.init(plugins: [NetworkLoggerPlugin()])
    }
    
}
