//
//  DetectItAPITarget.swift
//  DetectItAPI
//
//  Created by Илья Харабет on 26/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Moya
import DetectItCore

public enum DetectItAPITarget {
    
    case auth(alias: String, password: String)
    
    case feed
    
    case tasksBundle(bundleID: String)
        
    case taskScore(taskID: String, taskKind: String, bundleID: String?)
    case setTaskScore(taskID: String, taskKind: String, bundleID: String?, score: Int)
    
    case cipherAnswer(taskID: String)
    case setCipherAnswer(taskID: String, answer: String)
    
    case profileAnswers(taskID: String)
    case setProfileAnswers(taskID: String, answers: [[String: Any]])
    
    case totalScore
    
}

extension DetectItAPITarget: TargetType {
    
    public var baseURL: URL {
        #if DEBUG
        return URL(string: "http://localhost:8080")!
        #else
        return URL(string: "https://detect-api.herokuapp.com")!
        #endif
    }
    
    public var path: String {
        switch self {
        case .auth: return "auth"
        case .feed: return "feed"
        case .tasksBundle: return "tasksBundle"
        case .taskScore, .setTaskScore: return "taskScore"
        case .totalScore: return "totalScore"
        case .cipherAnswer, .setCipherAnswer: return "cipherAnswer"
        case .profileAnswers, .setProfileAnswers: return "profileAnswer"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .auth, .setTaskScore, .setCipherAnswer, .setProfileAnswers:
            return .post
        case .feed, .tasksBundle, .taskScore, .cipherAnswer, .profileAnswers, .totalScore:
            return .get
        }
    }
    
    public var sampleData: Data { Data() }
    
    public var task: Moya.Task {
        switch self {
        case let .auth(alias, password):
            return .requestParameters(
                parameters: ["alias": alias, "password": password],
                encoding: JSONEncoding.default
            )
        case .feed:
            return .requestParameters(
                parameters: [:],
                encoding: URLEncoding.default
            )
        case let .tasksBundle(bundleID):
            return .requestParameters(
                parameters: ["bundleID": bundleID],
                encoding: URLEncoding.default
            )
        case .totalScore:
            return .requestPlain
        case let .taskScore(taskID, taskKind, bundleID):
            var parameters: [String: Any] = ["taskID": taskID, "taskKind": taskKind]
            bundleID.map { parameters["bundleID"] = $0 }
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.default
            )
        case let .setTaskScore(taskID, taskKind, bundleID, score):
            var parameters: [String: Any] = ["taskID": taskID, "taskKind": taskKind, "score": score]
            bundleID.map { parameters["bundleID"] = $0 }
            return .requestParameters(
                parameters: parameters,
                encoding: JSONEncoding.default
            )
        case let .cipherAnswer(taskID):
            return .requestParameters(
                parameters: ["taskID": taskID],
                encoding: URLEncoding.default
            )
        case let .setCipherAnswer(taskID, answer):
            return .requestParameters(
                parameters: ["taskID": taskID, "taskKind": "cipher", "answer": answer],
                encoding: JSONEncoding.default
            )
        case let .profileAnswers(taskID):
            return .requestParameters(
                parameters: ["taskID": taskID],
                encoding: URLEncoding.default
            )
        case let .setProfileAnswers(taskID, answers):
            return .requestParameters(
                parameters: ["taskID": taskID, "taskKind": "profile", "answers": answers],
                encoding: JSONEncoding.default
            )
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .auth:
            return nil
        default:
            guard let user = User.shared.alias, let password = User.shared.password else { return nil }
            guard let token = "\(user):\(password)".data(using: .utf8)?.base64EncodedString() else { return nil }
            
            return ["Authorization": "Basic \(token)"]
        }
    }
    
}
