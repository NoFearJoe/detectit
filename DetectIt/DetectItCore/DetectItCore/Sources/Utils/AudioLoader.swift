//
//  AudioLoader.swift
//  DetectItCore
//
//  Created by Илья Харабет on 09.08.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public final class AudioLoader {
    
    public static let shared = AudioLoader()
    
    private init() {}
    
    private var inMemoryCache: [String: Data] = [:]
    private let persistantCache = PersistantCache()
    
    private let cacheQueue = DispatchQueue(label: "AudioLoaderQueue", qos: .userInitiated, attributes: .concurrent)
    
    public func load(
        path: String,
        completion: @escaping (Data?, _ cached: Bool) -> Void
    ) {
        let completionOnMain: (Data?, Bool) -> Void = { audio, cached in
            if Thread.current.isMainThread {
                completion(audio, cached)
            } else {
                DispatchQueue.main.async {
                    completion(audio, cached)
                }
            }
        }

        let domain: String = {
            #if DEBUG
            return "http://localhost:8080"
            #else
            return "https://detect-api.herokuapp.com"
            #endif
        }()
        
        guard let url = URL(string: domain)?.appendingPathComponent(path) else {
            return completion(nil, false)
        }
        
        loadFromNetwork(
            url: url,
            completion: completionOnMain
        )
    }
    
    private func loadFromNetwork(
        url: URL,
        completion: @escaping (Data?, Bool) -> Void
    ) {
        if let cachedAudio = getCachedAudio(url: url) {
            return completion(cachedAudio, true)
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.saveAudioToCache(audio: data, url: url)
                
                completion(data, false)
            }
        }.resume()
    }
    
    private func getCachedAudio(url: URL) -> Data? {
        let key = url.pathComponents.suffix(3).joined(separator: "_")
        
        if let inMemoryAudio = inMemoryCache[key] {
            return inMemoryAudio
        } else if let persistantAudio = persistantCache.get(key: key) {
            inMemoryCache[key] = persistantAudio
            return persistantAudio
        }
        
        return nil
    }
    
    private func saveAudioToCache(audio: Data?, url: URL) {
        cacheQueue.async {
            let key = url.pathComponents.suffix(3).joined(separator: "_")
        
            self.inMemoryCache[key] = audio
            self.persistantCache.save(audio: audio, key: key)
        }
    }
    
}

private extension AudioLoader {
    
    final class PersistantCache {
        
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("Audios", isDirectory: true)
        
        init() {
            guard let url = url, !FileManager.default.fileExists(atPath: url.path) else {
                return
            }
            
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        func save(audio: Data?, key: String) {
            guard let path = url?.appendingPathComponent(key) else { return }
            
            if let audio = audio {
                try? audio.write(to: path)
            } else {
                try? FileManager.default.removeItem(at: path)
            }
        }
        
        func get(key: String) -> Data? {
            guard let path = url?.appendingPathComponent(key) else { return nil }
            
            return FileManager.default.contents(atPath: path.path)
        }
        
    }
    
}
