//
//  ProfileTaskScreenDataLoader.swift
//  DetectIt
//
//  Created by Илья Харабет on 09/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

final class ProfileTaskScreenDataLoader {
    
    static func loadData(
        task: ProfileTask,
        completion: @escaping ([String: UIImage]) -> Void
    ) {
        let casePictures: [String] = task.cases.compactMap { $0.evidencePicture?.pictureName }
        
        let attachmentPictures: [String] = task.attachments?.compactMap { $0.pictureName } ?? []
        
        let allPictures = casePictures + attachmentPictures
        
        guard !allPictures.isEmpty else {
            return completion([:])
        }
        
        let dispatchGroup = DispatchGroup()
        
        var result: [String: UIImage] = [:]
        
        allPictures.forEach { picture in
            dispatchGroup.enter()
            
            ImageLoader.share.load(
                .staticAPI(picture),
                postprocessing: { $0.applyingOldPhotoFilter() }
            ) { image in
                result[picture] = image
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(result)
        }
    }
    
}
