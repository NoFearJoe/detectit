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
    
}
