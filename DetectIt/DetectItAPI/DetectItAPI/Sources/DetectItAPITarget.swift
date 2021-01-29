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
    
    case auth(alias: String, email: String, password: String)
    case restorePassword(email: String)
    case deleteAccount
    
    case feed(filters: [FeedFilter])
    
    case tasksBundle(bundleID: String)
        
    case taskScore(taskID: String, taskKind: String, bundleID: String?)
    case setTaskScore(taskID: String, taskKind: String, bundleID: String?, score: Int)
    
    case taskRating(taskID: String, taskKind: String, bundleID: String?)
    case setTaskRating(taskID: String, taskKind: String, bundleID: String?, rating: Double)
    
    case cipherAnswer(taskID: String)
    case setCipherAnswer(taskID: String, answer: String)
    
    case profileAnswers(taskID: String)
    case setProfileAnswers(taskID: String, answers: [[String: Any]])
    
    case questAnswer(taskID: String)
    case setQuestAnswer(taskID: String, answer: [String: Any])
    
    case totalScore
    
    case detectiveProfile
    
    case leaderboard
    
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
        case .restorePassword: return "auth/restore_password"
        case .deleteAccount: return "delete_account"
        case .feed: return "feed"
        case .tasksBundle: return "tasksBundle"
        case .taskScore, .setTaskScore: return "taskScore"
        case .taskRating, .setTaskRating: return "taskRating"
        case .totalScore: return "totalScore"
        case .cipherAnswer, .setCipherAnswer: return "cipherAnswer"
        case .profileAnswers, .setProfileAnswers: return "profileAnswer"
        case .questAnswer, .setQuestAnswer: return "questAnswer"
        case .detectiveProfile: return "detectiveProfile"
        case .leaderboard: return "leaderboard"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .auth, .deleteAccount, .setTaskScore, .setTaskRating, .setCipherAnswer, .setProfileAnswers, .setQuestAnswer:
            return .post
        case .feed, .tasksBundle, .taskScore, .taskRating, .cipherAnswer, .profileAnswers, .questAnswer, .totalScore, .detectiveProfile, .leaderboard, .restorePassword:
            return .get
        }
    }
    
    public var sampleData: Data { Data() }
    
    public var task: Moya.Task {
        switch self {
        case let .auth(alias, email, password):
            return .requestParameters(
                parameters: ["alias": alias, "email": email, "password": password],
                encoding: JSONEncoding.default
            )
        case let .restorePassword(email):
            return .requestParameters(
                parameters: ["email": email],
                encoding: URLEncoding.default
            )
        case .deleteAccount:
            return .requestPlain
        case let .feed(filters):
            return .requestParameters(
                parameters: ["filters": filters.map { $0.rawValue }.joined(separator: ",")],
                encoding: URLEncoding.default
            )
        case let .tasksBundle(bundleID):
            return .requestParameters(
                parameters: ["bundleID": bundleID],
                encoding: URLEncoding.default
            )
        case .totalScore:
            return .requestPlain
        case let .taskScore(taskID, taskKind, bundleID), let .taskRating(taskID, taskKind, bundleID):
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
        case let .setTaskRating(taskID, taskKind, bundleID, rating):
            var parameters: [String: Any] = ["taskID": taskID, "taskKind": taskKind, "rating": rating]
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
        case let .questAnswer(taskID):
            return .requestParameters(
                parameters: ["taskID": taskID],
                encoding: URLEncoding.default
            )
        case let .setQuestAnswer(taskID, answer):
            return .requestParameters(
                parameters: ["taskID": taskID, "taskKind": "quest", "answer": answer],
                encoding: JSONEncoding.default
            )
        case .detectiveProfile, .leaderboard:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .auth, .restorePassword:
            return [
                "Version": AppInfo.version
            ]
        default:
            guard let user = User.shared.alias, let password = User.shared.password else { return nil }
            guard let token = "\(user):\(password)".data(using: .utf8)?.base64EncodedString() else { return nil }
            
            return [
                "Authorization": "Basic \(token)",
                "Version": AppInfo.version
            ]
        }
    }
    
}
