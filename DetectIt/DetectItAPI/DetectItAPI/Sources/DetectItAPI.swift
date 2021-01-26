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
    
    private let cache = Cache.default
    
    public enum Error: Swift.Error {
        case decodingError
    }
    
    public init() {
        #if DEBUG
        super.init(plugins: [NetworkLoggerPlugin()])
        #else
        super.init()
        #endif
    }
    
    @discardableResult
    public func obtain<T: Codable>(
        _ type: T.Type,
        target: DetectItAPITarget,
        cacheKey: Cache.Key,
        force: Bool = true,
        completion: @escaping (Result<T, MoyaError>) -> Void
    ) -> CancellableObtain {
        let cancellable = CancellableObtain()
        
        cache.load(type, key: cacheKey) { [weak self] cachedObject in
            guard let self = self, !cancellable.isCancelled else { return }
            
            if let cachedObject = cachedObject {
                completion(.success(cachedObject))
                
                if !force { return }
            }
            
            let cancellableRequest = self.request(target) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case let .success(response):
                    guard let object = try? JSONDecoder().decode(type, from: response.data) else {
                        return completion(.failure(.objectMapping(Error.decodingError, response)))
                    }
                    
                    self.cache.save(object, key: cacheKey) {
                        completion(.success(object))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }
            
            cancellable.cancellableRequest = cancellableRequest
        }
        
        return cancellable
    }
    
    public func chechAuthentication(completion: @escaping (Bool, UserEntity?) -> Void) {
        guard let alias = User.shared.alias, let email = User.shared.email, let password = User.shared.password else {
            return completion(false, nil)
        }
        
        request(.auth(alias: alias, email: email, password: password)) { result in
            if case .success(let payload) = result, (200...299) ~= payload.statusCode {
                completion(true, try? payload.map(UserEntity.self))
            } else {
                completion(false, nil)
            }
        }
    }
    
}

public final class CancellableObtain {
    var isCancelled: Bool = false
    var cancellableRequest: Moya.Cancellable?
    
    public func cancel() {
        isCancelled = true
        cancellableRequest?.cancel()
    }
}
