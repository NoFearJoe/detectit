//
//  ImageLoader.swift
//  DetectItCore
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public enum ImageSource {
    case file(URL)
    case staticAPI(String)
}

public final class ImageLoader {
    
    public static let share = ImageLoader()
    
    private init() {}
    
    private var inMemoryCache: [String: UIImage] = [:]
    private let persistantCache = PersistantCache()
    
    private let queue = DispatchQueue(
        label: "ImageLoaderQueue",
        qos: .default,
        attributes: .concurrent
    )
    
    private let cacheQueue = DispatchQueue.main
    
    public func load(
        _ source: ImageSource,
        postprocessing: ((UIImage) -> UIImage)? = nil,
        completion: @escaping (UIImage?, _ cached: Bool) -> Void
    ) {
        let completionOnMain: (UIImage?, Bool) -> Void = { image, cached in
            DispatchQueue.main.async {
                completion(image, cached)
            }
        }
        
        switch source {
        case let .file(url):
            loadFile(
                url: url,
                postprocessing: postprocessing,
                completion: completionOnMain
            )
        case let .staticAPI(path):
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
                postprocessing: postprocessing,
                completion: completionOnMain
            )
        }
    }
    
    private func loadFile(
        url: URL,
        postprocessing: ((UIImage) -> UIImage)? = nil,
        completion: @escaping (UIImage?, Bool) -> Void
    ) {
        queue.async {
            if let cachedImage = self.cacheQueue.sync(execute: { self.getCachedImage(url: url) }) {
                return completion(cachedImage, true)
            }
            
            let image = UIImage(contentsOfFile: url.path).flatMap { postprocessing?($0) ?? $0 }
            
            self.cacheQueue.sync {
                self.saveImageToCache(image: image, url: url)
            }
            
            completion(image, false)
        }
    }
    
    private func loadFromNetwork(
        url: URL,
        postprocessing: ((UIImage) -> UIImage)? = nil,
        completion: @escaping (UIImage?, Bool) -> Void
    ) {
        self.queue.async {
            if let cachedImage = self.cacheQueue.sync(execute: { self.getCachedImage(url: url) }) {
                return completion(cachedImage, true)
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                self.queue.async {
                    let image = data.flatMap { UIImage(data: $0).flatMap { postprocessing?($0) ?? $0 } }
                    
                    self.cacheQueue.sync {
                        self.saveImageToCache(image: image, url: url)
                    }
                    
                    completion(image, false)
                }
            }.resume()
        }
    }
    
    private func getCachedImage(url: URL) -> UIImage? {
        let key = url.pathComponents.suffix(3).joined(separator: "_")
        
        return inMemoryCache[key] ?? persistantCache.get(key: key)
    }
    
    private func saveImageToCache(image: UIImage?, url: URL) {
        let key = url.pathComponents.suffix(3).joined(separator: "_")
        
        inMemoryCache[key] = image
        persistantCache.save(image: image, key: key)
    }
    
}

private extension ImageLoader {
    
    final class PersistantCache {
        
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("Images", isDirectory: true)
        
        init() {
            guard let url = url, !FileManager.default.fileExists(atPath: url.path) else {
                return
            }
            
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        func save(image: UIImage?, key: String) {
            guard let path = url?.appendingPathComponent(key) else { return }
            
            if let image = image {
                if key.lowercased().hasSuffix("jpg") || key.lowercased().hasSuffix("jpeg") {
                    try? image.jpegData(compressionQuality: 1)?.write(to: path)
                } else {
                    try? image.pngData()?.write(to: path)
                }
            } else {
                try? FileManager.default.removeItem(at: path)
            }
        }
        
        func get(key: String) -> UIImage? {
            guard let path = url?.appendingPathComponent(key) else { return nil }
            
            return FileManager.default.contents(atPath: path.path).flatMap { UIImage(data: $0) }
        }
        
    }
    
}
