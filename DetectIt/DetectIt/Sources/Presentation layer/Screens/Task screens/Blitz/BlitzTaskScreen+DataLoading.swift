//
//  BlitzTaskScreen+DataLoading.swift
//  DetectIt
//
//  Created by Илья Харабет on 21.11.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

extension BlitzTaskScreen {
    
    func loadTask() {
        screenLoadingView.setVisible(true, animated: false)
        screenPlaceholderView.setVisible(false, animated: false)
        
        loadData(task: task) { [weak self] success in
            guard let self = self else { return }
            
            self.isDataLoaded = success
            
            self.screenView.reloadContent()
            self.updateContentState(animated: false)
            
            self.screenLoadingView.setVisible(false, animated: true)
            self.screenPlaceholderView.setVisible(!success, animated: false)
            
            if !success {
                Analytics.logScreenError(screen: .blitzTask)
            }
        }
    }
    
    func loadData(
        task: BlitzTask,
        completion: @escaping (Bool) -> Void
    ) {
        let attachmentPictures: [String] = task.attachments?.compactMap { $0.pictureName } ?? []
        let crimeDescriptionAttachmentPictures: [String] = task.crimeDescriptionAttachments?.compactMap { $0.pictureName } ?? []
        
        let allPictures = attachmentPictures + crimeDescriptionAttachmentPictures
        
        let dispatchGroup = DispatchGroup()
                
        var images: [String: UIImage] = [:]
        
        allPictures.forEach { picture in
            guard let url = URL(string: picture) else { return }
            
            dispatchGroup.enter()
            
            ImageLoader.shared.load(
                .file(url),
                postprocessing: { $0.applyingOldPhotoFilter() }
            ) { image, _ in
                images[picture] = image
                
                dispatchGroup.leave()
            }
        }
        
        let allAudios = task.attachments?.compactMap { $0.audioFileName } ?? []
        
        var audios: [String: Data] = [:]
        
        allAudios.forEach { audio in
            audios[audio] = FileManager.default.contents(atPath: audio)
        }
        
        loadScoreAndAnswer()
        
        dispatchGroup.notify(queue: .main) {
            self.images = images
            self.audios = audios
            
            completion(true)
        }
    }
    
    func loadScoreAndAnswer() {
        score = TaskScore.get(id: task.id, taskKind: task.kind)
        answer.answer = TaskAnswer.get(blitzTaskID: task.id)
    }
    
    func saveScoreAndAnswer(_ score: Int, answer: TaskAnswer.BlitzTaskAnswer) {
        TaskScore.set(value: score, id: task.id, taskKind: task.kind)
        TaskAnswer.set(answer: answer, blitzTaskID: task.id)
    }
    
}
