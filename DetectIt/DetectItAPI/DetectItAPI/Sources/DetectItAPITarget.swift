//
//  DetectItAPITarget.swift
//  DetectItAPI
//
//  Created by Илья Харабет on 26/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Moya

public enum DetectItAPITarget {
    
    case feed(userID: Int)
    
}

extension DetectItAPITarget: TargetType {
    
    public var baseURL: URL {
        URL(string: "http://localhost:8080")!
    }
    
    public var path: String {
        switch self {
        case .feed: return "feed"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .feed: return .get
        }
    }
    
    public var sampleData: Data { Data() }
    
    public var task: Task {
        switch self {
        case let .feed(userID):
            return .requestParameters(parameters: ["userID": userID], encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        nil
    }
    
}
