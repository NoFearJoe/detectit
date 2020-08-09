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
    
    public static let shared = ImageLoader()
    
    private init() {}
    
    private var inMemoryCache: [String: UIImage] = [:]
    private let persistantCache = PersistantCache()
    
    private let cacheQueue = DispatchQueue(label: "ImageLoaderQueue", qos: .userInitiated, attributes: .concurrent)
    
    public func load(
        _ source: ImageSource,
        postprocessing: ((UIImage) -> UIImage)? = nil,
        completion: @escaping (UIImage?, _ cached: Bool) -> Void
    ) {
        let completionOnMain: (UIImage?, Bool) -> Void = { image, cached in
            if Thread.current.isMainThread {
                completion(image, cached)
            } else {
                DispatchQueue.main.async {
                    completion(image, cached)
                }
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
        if let cachedImage = getCachedImage(url: url) {
            return completion(cachedImage, true)
        }
        
        let image = UIImage(contentsOfFile: url.path).flatMap { postprocessing?($0) ?? $0 }
        
        saveImageToCache(image: image, url: url)
        
        completion(image, false)
    }
    
    private func loadFromNetwork(
        url: URL,
        postprocessing: ((UIImage) -> UIImage)? = nil,
        completion: @escaping (UIImage?, Bool) -> Void
    ) {
        if let cachedImage = getCachedImage(url: url) {
            return completion(cachedImage, true)
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                let image = data.flatMap { UIImage(data: $0).flatMap { postprocessing?($0) ?? $0 } }
                
                self.saveImageToCache(image: image, url: url)
                
                completion(image, false)
            }
        }.resume()
    }
    
    private func getCachedImage(url: URL) -> UIImage? {
        let key = url.pathComponents.suffix(3).joined(separator: "_")
        
        if let inMemoryImage = inMemoryCache[key] {
            return inMemoryImage
        } else if let persistantImage = persistantCache.get(key: key) {
            inMemoryCache[key] = persistantImage
            return persistantImage
        }
        
        return nil
    }
    
    private func saveImageToCache(image: UIImage?, url: URL) {
        cacheQueue.async {
            let key = url.pathComponents.suffix(3).joined(separator: "_")
        
            self.inMemoryCache[key] = image
            self.persistantCache.save(image: image, key: key)
        }
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
