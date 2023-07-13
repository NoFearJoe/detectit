import Foundation

public final class FeedService {
    
    public init() {}
    
    public func obtainFeed() async -> [FeedItem] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                guard
                    let path = Bundle.main.path(forResource: "Feed", ofType: "json", inDirectory: "Tasks"),
                    let feedFile = FileManager.default.contents(atPath: path),
                    let feed = try? JSONDecoder().decode([FeedItem].self, from: feedFile)
                else {
                    return continuation.resume(returning: [])
                }
                
                continuation.resume(returning: feed)
            }
        }
    }
    
    public func obtainFeedItem(meta: FeedItem) async -> Feed.Item? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                switch meta.kind {
                case .cipher:
                    let cipher = self.obtainCipher(id: meta.id)
                    continuation.resume(returning: cipher)
                case .blitz:
                    let blitz = self.obtainBlitz(id: meta.id)
                    continuation.resume(returning: blitz)
                case .profile:
                    let profile = self.obtainProfile(id: meta.id)
                    continuation.resume(returning: profile)
                case .quest:
                    let quest = self.obtainQuest(id: meta.id)
                    continuation.resume(returning: quest)
                }
            }
        }
    }
    
}

private extension FeedService {
    func obtainCipher(id: String) -> Feed.Item? {
        let dir = "Tasks/CipherTasks/\(id)"
        
        guard
            let path = Bundle.main.path(forResource: "task", ofType: "json", inDirectory: dir),
            let data = FileManager.default.contents(atPath: path),
            var task = try? JSONDecoder().decode(DecoderTask.self, from: data)
        else {
            return nil
        }
        
        if let picture = task.encodedPictureName {
            task.encodedPictureName = getPicture(picture, dir: dir)
        }
        if let audio = task.encodedAudioName {
            task.encodedAudioName = getAudio(audio, dir: dir)
        }
        
        let score = TaskScore.get(id: id, taskKind: .cipher)
        
        return Feed.Item(
            id: id,
            kind: .cipher,
            title: task.title,
            subtitle: task.preposition,
            picture: task.encodedPictureName,
            difficulty: task.taskDifficulty.rawValue,
            score: score,
            maxScore: task.maxScore,
            completed: score != nil,
            cipher: task,
            profile: nil,
            blitz: nil,
            quest: nil
        )
    }
    
    func obtainProfile(id: String) -> Feed.Item? {
        let dir = "Tasks/ProfileTasks/\(id)"
        
        guard
            let path = Bundle.main.path(forResource: "task", ofType: "json", inDirectory: dir),
            let data = FileManager.default.contents(atPath: path),
            var task = try? JSONDecoder().decode(ProfileTask.self, from: data)
        else {
            return nil
        }
        
        let picture = getPicture("image.jpg", dir: dir)
        
        task.attachments = task.attachments?.map {
            var a = $0
            
            if let picture = a.pictureName {
                a.pictureName = getPicture(picture, dir: dir)
            }
            if let audio = a.audioFileName {
                a.audioFileName = getAudio(audio, dir: dir)
            }
            
            return a
        }
        
        task.cases = task.cases.map {
            var `case` = $0
            
            if let picture = `case`.evidencePicture?.pictureName {
                `case`.evidencePicture?.pictureName = getPicture(picture, dir: dir) ?? picture
            }
            
            return `case`
        }
        
        let score = TaskScore.get(id: id, taskKind: .profile)
        
        return Feed.Item(
            id: id,
            kind: .profile,
            title: task.title,
            subtitle: task.preposition,
            picture: picture,
            difficulty: task.taskDifficulty.rawValue,
            score: score,
            maxScore: task.maxScore,
            completed: score != nil,
            cipher: nil,
            profile: task,
            blitz: nil,
            quest: nil
        )
    }
    
    func obtainBlitz(id: String) -> Feed.Item? {
        let dir = "Tasks/BlitzTasks/\(id)"
        
        guard
            let path = Bundle.main.path(forResource: "task", ofType: "json", inDirectory: dir),
            let data = FileManager.default.contents(atPath: path),
            var task = try? JSONDecoder().decode(BlitzTask.self, from: data)
        else {
            return nil
        }
        
        let picture = getPicture("image.jpg", dir: dir)
        
        task.attachments = task.attachments?.map {
            var a = $0
            
            if let picture = a.pictureName {
                a.pictureName = getPicture(picture, dir: dir)
            }
            if let audio = a.audioFileName {
                a.audioFileName = getAudio(audio, dir: dir)
            }
            
            return a
        }
        
        task.crimeDescriptionAttachments = task.crimeDescriptionAttachments?.map {
            var a = $0
            
            if let picture = a.pictureName {
                a.pictureName = getPicture(picture, dir: dir)
            }
            if let audio = a.audioFileName {
                a.audioFileName = getAudio(audio, dir: dir)
            }
            
            return a
        }
        
        let score = TaskScore.get(id: id, taskKind: .blitz)
        
        return Feed.Item(
            id: id,
            kind: .blitz,
            title: task.title,
            subtitle: task.preposition,
            picture: picture,
            difficulty: task.taskDifficulty.rawValue,
            score: score,
            maxScore: task.maxScore,
            completed: score != nil,
            cipher: nil,
            profile: nil,
            blitz: task,
            quest: nil
        )
    }
    
    func obtainQuest(id: String) -> Feed.Item? {
        let dir = "Tasks/QuestTasks/\(id)"
        
        guard
            let path = Bundle.main.path(forResource: "task", ofType: "json", inDirectory: dir),
            let data = FileManager.default.contents(atPath: path),
            var task = try? JSONDecoder().decode(QuestTask.self, from: data)
        else {
            return nil
        }
        
        let picture = getPicture("image.jpg", dir: dir)
        
        let score = TaskScore.get(id: id, taskKind: .profile)
        
        return Feed.Item(
            id: id,
            kind: .quest,
            title: task.title,
            subtitle: task.preposition,
            picture: picture,
            difficulty: task.taskDifficulty.rawValue,
            score: score,
            maxScore: task.maxScore,
            completed: score != nil,
            cipher: nil,
            profile: nil,
            blitz: nil,
            quest: task
        )
    }
    
    private func getPicture(_ name: String, dir: String) -> String? {
        Bundle.main.path(forResource: name, ofType: nil, inDirectory: dir)
    }
    
    private func getAudio(_ name: String, dir: String) -> String? {
        Bundle.main.path(forResource: name, ofType: nil, inDirectory: dir)
    }
}
