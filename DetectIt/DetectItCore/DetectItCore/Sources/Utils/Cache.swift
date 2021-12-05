//
//  Cache.swift
//  DetectItCore
//
//  Created by Илья Харабет on 04/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public final class Cache {
    
    public static let `default` = Cache(identifier: "default_cache")
    
    private let fileManager = FileManager.default
    
    private let queue: DispatchQueue
    
    private let identifier: String
    
    public init(identifier: String) {
        self.identifier = identifier
        self.queue = DispatchQueue(label: "cache_\(identifier)")
    }
    
    public func load<T: Decodable>(_ type: T.Type, key: Key) -> T? {
        queue.sync {
            let object = self.getObject(type, key: key)
            
            return DispatchQueue.main.sync { object }
        }
    }
    
    public func load<T: Decodable>(_ type: T.Type, key: Key, completion: @escaping (T?) -> Void) {
        queue.async {
            let object = self.getObject(type, key: key)
            
            DispatchQueue.main.async {
                completion(object)
            }
        }
    }
    
    public func save<T: Encodable>(_ object: T, key: Key, completion: (() -> Void)? = nil) {
        queue.async {
            guard
                let url = self.fileURL(for: key),
                let data = try? JSONEncoder().encode(object)
            else {
                return DispatchQueue.main.sync {
                    completion?()
                }
            }
            
            if !self.fileManager.fileExists(atPath: url.deletingLastPathComponent().path) {
                try? self.fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            }
            
            self.fileManager.createFile(atPath: url.path, contents: nil, attributes: nil)
            
            try? data.write(to: url, options: .completeFileProtection)
            
            DispatchQueue.main.sync {
                completion?()
            }
        }
    }
    
    public func removeAll(completion: (() -> Void)? = nil) {
        queue.async {
            guard let url = self.cacheURL() else {
                return DispatchQueue.main.sync {
                    completion?()
                }
            }
            
            try? self.fileManager.removeItem(at: url)
            
            DispatchQueue.main.sync {
                completion?()
            }
        }
    }
    
    private func cacheURL() -> URL? {
        let cacheDirectory = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return cacheDirectory?.appendingPathComponent("Cache")
    }
    
    private func fileURL(for key: Key) -> URL? {
        cacheURL()?.appendingPathComponent(key.string)
    }
    
    private func getObject<T: Decodable>(_ type: T.Type, key: Key) -> T? {
        guard
            let url = self.fileURL(for: key),
            let data = try? Data(contentsOf: url),
            let object = try? JSONDecoder().decode(type, from: data)
        else {
            return nil
        }
        
        if let attributes = try? fileManager.attributesOfItem(atPath: url.path),
           let creationDate = attributes[.creationDate] as? Date,
           abs(creationDate.timeIntervalSinceNow) > key.lifetime {
            return nil
        }
        
        return object
    }
    
}

public extension Cache {
    
    struct Key {
        
        let string: String
        let lifetime: TimeInterval
        
        public static let defaultLifetime: TimeInterval = 3600 * 24 * 7
        
        public init(_ string: String, lifetime: TimeInterval = Self.defaultLifetime) {
            self.string = string
            self.lifetime = lifetime
        }
        
        public init(_ array: [String], lifetime: TimeInterval = Self.defaultLifetime) {
            self.string = array.joined()
            self.lifetime = lifetime
        }
        
    }
    
}
