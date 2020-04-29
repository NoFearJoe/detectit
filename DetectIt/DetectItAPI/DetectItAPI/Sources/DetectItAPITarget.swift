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
        
    case taskScore(userID: Int, taskID: String, taskKind: String, bundleID: String?)
    case setTaskScore(userID: Int, taskID: String, taskKind: String, bundleID: String?, score: Int)
    
    case cipherAnswer(userID: Int, taskID: String)
    case setCipherAnswer(userID: Int, taskID: String, answer: String)
    
    case profileAnswers(userID: Int, taskID: String)
    case setProfileAnswers(userID: Int, taskID: String, answers: [[String: Any]])
    
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
        case .taskScore, .setTaskScore: return "taskScore"
        case .cipherAnswer, .setCipherAnswer: return "cipherAnswer"
        case .profileAnswers, .setProfileAnswers: return "profileAnswer"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .createUser, .setTaskScore, .setCipherAnswer, .setProfileAnswers:
            return .post
        case .feed, .tasksBundle, .taskScore, .cipherAnswer, .profileAnswers:
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
        case let .taskScore(userID, taskID, taskKind, bundleID):
            var parameters: [String: Any] = ["userID": userID, "taskID": taskID, "taskKind": taskKind]
            bundleID.map { parameters["bundleID"] = $0 }
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.default
            )
        case let .setTaskScore(userID, taskID, taskKind, bundleID, score):
            var parameters: [String: Any] = ["userID": userID, "taskID": taskID, "taskKind": taskKind, "score": score]
            bundleID.map { parameters["bundleID"] = $0 }
            return .requestParameters(
                parameters: parameters,
                encoding: JSONEncoding.default
            )
        case let .cipherAnswer(userID, taskID):
            return .requestParameters(
                parameters: ["userID": userID, "taskID": taskID],
                encoding: URLEncoding.default
            )
        case let .setCipherAnswer(userID, taskID, answer):
            return .requestParameters(
                parameters: ["userID": userID, "taskID": taskID, "taskKind": "cipher", "answer": answer],
                encoding: JSONEncoding.default
            )
        case let .profileAnswers(userID, taskID):
            return .requestParameters(
                parameters: ["userID": userID, "taskID": taskID],
                encoding: URLEncoding.default
            )
        case let .setProfileAnswers(userID, taskID, answers):
            return .requestParameters(
                parameters: ["userID": userID, "taskID": taskID, "taskKind": "profile", "answers": answers],
                encoding: JSONEncoding.default
            )
        }
    }
    
    public var headers: [String : String]? {
        nil
    }
    
}
