//
//  ProfileTaskScreen+DataLoading.swift
//  DetectIt
//
//  Created by Илья Харабет on 09/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

extension ProfileTaskScreen {
    
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
                Analytics.logScreenError(screen: .profileTask)
            }
        }
    }
    
    func loadData(
        task: ProfileTask,
        completion: @escaping (Bool) -> Void
    ) {
        let casePictures: [String] = task.cases.compactMap { $0.evidencePicture?.pictureName }
        
        let attachmentPictures: [String] = task.attachments?.compactMap { $0.pictureName } ?? []
        
        let allPictures = casePictures + attachmentPictures
        
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
        answers.answers = TaskAnswer.get(profileTaskID: task.id) ?? []
    }
    
    func saveScoreAndAnswer(_ score: Int, answers: [TaskAnswer.ProfileTaskAnswer]) {
        TaskScore.set(value: score, id: task.id, taskKind: task.kind)
        TaskAnswer.set(answers: answers, profileTaskID: task.id)
    }
    
}
