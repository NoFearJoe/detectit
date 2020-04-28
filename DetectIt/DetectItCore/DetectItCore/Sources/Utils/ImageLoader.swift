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
    
    private var cache: [String: UIImage] = [:]
    
    private let queue = DispatchQueue(
        label: "ImageLoaderQueue",
        qos: .default,
        attributes: .concurrent
    )
    
    private let cacheQueue = DispatchQueue.main
    
    public func load(
        _ source: ImageSource,
        postprocessing: ((UIImage) -> UIImage)? = nil,
        completion: @escaping (UIImage?) -> Void
    ) {
        let completionOnMain: (UIImage?) -> Void = { image in
            DispatchQueue.main.async {
                completion(image)
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
            // TODO
            guard let url = URL(string: "http://localhost:8080")?.appendingPathComponent(path) else {
                return completion(nil)
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
        completion: @escaping (UIImage?) -> Void
    ) {
        queue.async {
            if let cachedImage = self.cacheQueue.sync(execute: { self.cache[url.path] }) {
                return completion(cachedImage)
            }
            
            let image = UIImage(contentsOfFile: url.path).flatMap { postprocessing?($0) ?? $0 }
            
            self.cacheQueue.sync {
                self.cache[url.path] = image
            }
            
            completion(image)
        }
    }
    
    private func loadFromNetwork(
        url: URL,
        postprocessing: ((UIImage) -> UIImage)? = nil,
        completion: @escaping (UIImage?) -> Void
    ) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            self.queue.async {
                if let cachedImage = self.cacheQueue.sync(execute: { self.cache[url.path] }) {
                    return completion(cachedImage)
                }
                
                let image = data.flatMap { UIImage(data: $0).flatMap { postprocessing?($0) ?? $0 } }
                
                self.cacheQueue.sync {
                    self.cache[url.path] = image
                }
                
                completion(image)
            }
        }.resume()
    }
    
}
