import DetectItCore

extension DecoderTaskScreen {
    
    func loadTask() {
        screenLoadingView.setVisible(true, animated: false)
        screenPlaceholderView.setVisible(false, animated: false)
        
        loadData { [weak self] success in
            guard let self = self else { return }
            
            guard success, self.checkIfContentLoaded() == true else {
                self.screenPlaceholderView.setVisible(true, animated: false)
                self.screenLoadingView.setVisible(false, animated: true)
                self.screenPlaceholderView.configure(
                    title: "network_error_title".localized,
                    message: "network_error_message".localized,
                    onRetry: { [unowned self] in self.loadTask() },
                    onClose: { [unowned self] in self.dismiss(animated: true, completion: nil) },
                    onReport: nil
                )
                
                Analytics.logScreenError(screen: .cipherTask)
                
                return
            }
            
            self.screenLoadingView.setVisible(false, animated: true)
            self.displayContent()
            self.updateContentState(animated: false)
        }
    }
    
    private func loadData(completion: @escaping (Bool) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var isDataLoaded = true
        
        switch task.decodedResource {
        case .nothing:
            break
        case let .picture(path):
            guard let url = URL(string: path) else { break }
            
            dispatchGroup.enter()
            ImageLoader.shared.load(
                .file(url)
            ) { [weak self] image, _ in
                self?.encodedImage = image
                isDataLoaded = image != nil ? isDataLoaded : false
                dispatchGroup.leave()
            }
        case let .audio(path):
            encodedAudio = FileManager.default.contents(atPath: path)
            isDataLoaded = encodedAudio != nil ? isDataLoaded : false
        case let .pictureAndAudio(picturePath, audioPath):
            guard let url = URL(string: picturePath) else { break }
            
            dispatchGroup.enter()
            ImageLoader.shared.load(
                .file(url)
            ) { [weak self] image, _ in
                self?.encodedImage = image
                isDataLoaded = image != nil ? isDataLoaded : false
                dispatchGroup.leave()
            }
            
            encodedAudio = FileManager.default.contents(atPath: audioPath)
            isDataLoaded = encodedAudio != nil ? isDataLoaded : false
        }
        
        loadScoreAndAnswer()
        
        dispatchGroup.notify(queue: .main) {
            completion(isDataLoaded)
        }
    }
    
    private func loadScoreAndAnswer() {
        score = TaskScore.get(id: task.id, taskKind: task.kind)
        answer = TaskAnswer.get(decoderTaskID: task.id)
    }
    
    func saveScoreAndAnswer(_ score: Int, answer: String) {
        TaskScore.set(value: score, id: task.id, taskKind: task.kind)
        TaskAnswer.set(answer: answer, decoderTaskID: task.id)
    }
    
}
