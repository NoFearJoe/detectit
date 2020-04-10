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
        bundleID: String,
        completion: @escaping ([String: UIImage]) -> Void
    ) {
        let casePictures: [(String, URL)] = task.cases.compactMap {
            guard
                let pictureName = $0.evidencePicture?.pictureName,
                let pictureURL = task.casePictureURL(case: $0, bundleID: bundleID)
            else {
                return nil
            }
            
            return (pictureName, pictureURL)
        }
        
        let attachmentPictures: [(String, URL)] = task.attachments?.compactMap {
            guard
                let pictureName = $0.pictureName,
                let pictureURL = task.attachmentURL(attachment: $0, bundleID: bundleID)
            else {
                return nil
            }
            
            return (pictureName, pictureURL)
        } ?? []
        
        let allPictures = casePictures + attachmentPictures
        
        guard !allPictures.isEmpty else {
            return completion([:])
        }
        
        let dispatchGroup = DispatchGroup()
        
        var result: [String: UIImage] = [:]
        
        allPictures.forEach { picture in
            dispatchGroup.enter()
            
            ImageLoader.share.load(
                .file(picture.1),
                postprocessing: { $0.applyingOldPhotoFilter() }
            ) { image in
                result[picture.0] = image
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(result)
        }
    }
    
}
