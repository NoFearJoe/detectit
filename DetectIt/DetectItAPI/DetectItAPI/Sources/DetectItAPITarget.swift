//
//  DetectItAPITarget.swift
//  DetectItAPI
//
//  Created by Илья Харабет on 26/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Moya

public enum DetectItAPITarget {
    
    case createUser(alias: String)
    
    case feed(userID: Int)
    
    case tasksBundle(userID: Int, bundleID: String)
    
}

extension DetectItAPITarget: TargetType {
    
    public var baseURL: URL {
        URL(string: "http://localhost:8080")!
    }
    
    public var path: String {
        switch self {
        case .createUser: return "user"
        case .feed: return "feed"
        case .tasksBundle: return "tasksBundle"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .createUser:
            return .post
        case .feed, .tasksBundle:
            return .get
        }
    }
    
    public var sampleData: Data { Data() }
    
    public var task: Task {
        switch self {
        case let .createUser(alias):
            return .requestParameters(
                parameters: ["alias": alias],
                encoding: JSONEncoding.default
            )
        case let .feed(userID):
            return .requestParameters(
                parameters: ["userID": userID],
                encoding: URLEncoding.default
            )
        case let .tasksBundle(userID, bundleID):
            return .requestParameters(
                parameters: ["userID": userID, "bundleID": bundleID],
                encoding: URLEncoding.default
            )
        }
    }
    
    public var headers: [String : String]? {
        nil
    }
    
}
