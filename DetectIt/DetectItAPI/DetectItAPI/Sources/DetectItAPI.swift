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
        super.init(plugins: [NetworkLoggerPlugin()])
    }
    
    public func obtain<T: Codable>(
        _ type: T.Type,
        target: DetectItAPITarget,
        cacheKey: Cache.Key,
        force: Bool = true,
        completion: @escaping (Result<T, MoyaError>) -> Void
    ) {
        cache.load(type, key: cacheKey) { [weak self] cachedObject in
            guard let self = self else { return }
            
            if let cachedObject = cachedObject {
                completion(.success(cachedObject))
                
                if !force { return }
            }
            
            self.request(target) { [weak self] result in
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
        }
    }
    
}
