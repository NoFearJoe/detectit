import Foundation
import DetectItCore

public final class FeedService {
    
    public init() {}
    
    public func obtainFeed(_ completion: @escaping ([FeedItem]) -> Void) {
        DispatchQueue.global().async {
            guard
                let path = Bundle.main.path(forResource: "Feed", ofType: "json", inDirectory: "Tasks"),
                let feedFile = FileManager.default.contents(atPath: path),
                let feed = try? JSONDecoder().decode([FeedItem].self, from: feedFile)
            else {
                return DispatchQueue.main.sync { completion([]) }
            }
            
            DispatchQueue.main.sync { completion(feed) }
        }
    }
    
    public func obtainFeedItem(meta: FeedItem, completion: @escaping (Feed.Item?) -> Void) {
        DispatchQueue.global().async {
            switch meta.kind {
            case .cipher:
                let cipher = self.obtainCipher(id: meta.id)
                DispatchQueue.main.sync {
                    completion(cipher)
                }
            case .blitz:
                let blitz = self.obtainBlitz(id: meta.id)
                DispatchQueue.main.sync {
                    completion(blitz)
                }
            case .profile:
                let profile = self.obtainProfile(id: meta.id)
                DispatchQueue.main.sync {
                    completion(profile)
                }
            case .quest:
                let quest = self.obtainQuest(id: meta.id)
                DispatchQueue.main.sync {
                    completion(quest)
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
        
        return Feed.Item(
            id: id,
            kind: .cipher,
            title: task.title,
            subtitle: task.preposition,
            picture: nil,
            difficulty: task.taskDifficulty.rawValue,
            score: nil,
            maxScore: task.maxScore,
            completed: false, // TODO
            rating: nil,
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
        
        return Feed.Item(
            id: id,
            kind: .profile,
            title: task.title,
            subtitle: task.preposition,
            picture: picture,
            difficulty: task.taskDifficulty.rawValue,
            score: nil,
            maxScore: task.maxScore,
            completed: false,
            rating: nil,
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
        
        return Feed.Item(
            id: id,
            kind: .blitz,
            title: task.title,
            subtitle: task.preposition,
            picture: picture,
            difficulty: task.taskDifficulty.rawValue,
            score: nil,
            maxScore: task.maxScore,
            completed: false,
            rating: nil,
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
        
        return Feed.Item(
            id: id,
            kind: .quest,
            title: task.title,
            subtitle: task.preposition,
            picture: picture,
            difficulty: task.taskDifficulty.rawValue,
            score: nil,
            maxScore: task.maxScore,
            completed: false,
            rating: nil,
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
