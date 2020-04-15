//
//  MainScreenDataLoader.swift
//  DetectIt
//
//  Created by Илья Харабет on 05/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

final class MainScreenDataLoader {
    
    typealias Data = (taskBundles: [TasksBundle.Info], taskBundleImages: [String: UIImage])
    
    static func loadData(completion: @escaping (Data?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            guard let taskBundlesRootURL = TasksBundleMap.taskBundlesRootURL else {
                return DispatchQueue.main.sync { completion(nil) }
            }
            
            guard let taskBundleIDs = try? FileManager.default.contentsOfDirectory(atPath: taskBundlesRootURL.path) else {
                return DispatchQueue.main.sync { completion(nil) }
            }
            
            var taskBundles: [TasksBundle.Info] = []
            var taskBundleImages: [String: UIImage] = [:]
            
            let dispatchGroup = DispatchGroup()
            
            taskBundleIDs.forEach {
                dispatchGroup.enter()
                
                TasksBundle.loadInfo(bundleID: $0) { bundle in
                    if let bundle = bundle {
                        taskBundles.append(bundle)
                        taskBundleImages[bundle.id] = bundle.imageURL.flatMap {
                            UIImage(contentsOfFile: $0.path)
                        } ?? UIImage()
                    }
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                taskBundles.sort(by: { $0.position < $1.position })
                
                completion(
                    (taskBundles, taskBundleImages)
                )
            }
        }
    }
    
    static func getPurchaseStates(
        bundleIDs: [String]
    ) -> [String: TasksBundlePurchaseState] {
        var result: [String: TasksBundlePurchaseState] = [:]
        
        bundleIDs.forEach {
            result[$0] = PaidTaskBundlesManager.tasksBundlePurchaseState(id: $0)
        }
        
        return result
    }
    
}
