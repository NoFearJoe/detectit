//
//  TasksBundleScreen+Section.swift
//  DetectIt
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

extension TasksBundleScreen {
    
    enum Section {
        case audiorecords
        case extraEvidences
        case ciphers
        case profiles
        case quests
        
        var title: String {
            switch self {
            case .audiorecords:
                return "Аудиофайлы"
            case .extraEvidences:
                return "Улики"
            case .ciphers:
                return "Шифры"
            case .profiles:
                return "Профайлы"
            case .quests:
                return "Квесты"
            }
        }
        
    }
    
    typealias SectionModel = (Section, [TasksBundleScreenTaskCell.Model])
    
    func makeSections(bundle: TasksBundle) -> [SectionModel] {
        var sections: [SectionModel] = []
        
        if !bundle.audiorecordTasks.isEmpty {
            sections.append(
                (.audiorecords, bundle.audiorecordTasks.map(map))
            )
        }
        
        if !bundle.extraEvidenceTasks.isEmpty {
            sections.append(
                (.extraEvidences, bundle.extraEvidenceTasks.map(map))
            )
        }
        
        if !bundle.decoderTasks.isEmpty {
            sections.append(
                (.ciphers, bundle.decoderTasks.map(map))
            )
        }
        
        if !bundle.profileTasks.isEmpty {
            sections.append(
                (.profiles, bundle.profileTasks.map(map))
            )
        }
        
        if !bundle.questTasks.isEmpty {
            sections.append(
                (.quests, bundle.questTasks.map(map))
            )
        }
        
        return sections
    }
    
    private func map(task: AudioRecordTask) -> TasksBundleScreenTaskCell.Model {
        let score = TaskScore.get(audioRecordTaskID: task.id).map(makeScoreString)
        
        return TasksBundleScreenTaskCell.Model(
            title: task.title,
            score: score,
            isEnabled: score == nil
        )
    }
    
    private func map(task: ExtraEvidenceTask) -> TasksBundleScreenTaskCell.Model {
        let score = TaskScore.get(extraEvidenceTaskID: task.id).map(makeScoreString)
        
        return TasksBundleScreenTaskCell.Model(
            title: task.title,
            score: score,
            isEnabled: score == nil
        )
    }
    
    private func map(task: DecoderTask) -> TasksBundleScreenTaskCell.Model {
        let score = TaskScore.get(decoderTaskID: task.id).map(makeScoreString)
        
        return TasksBundleScreenTaskCell.Model(
            title: task.title,
            score: score,
            isEnabled: score == nil
        )
    }
    
    private func map(task: ProfileTask) -> TasksBundleScreenTaskCell.Model {
        let score = TaskScore.get(profileTaskID: task.id).map(makeScoreString)
        
        return TasksBundleScreenTaskCell.Model(
            title: task.title,
            score: score,
            isEnabled: score == nil
        )
    }
    
    private func map(task: QuestTask) -> TasksBundleScreenTaskCell.Model {
        let score = TaskScore.get(questTaskID: task.id).map(makeScoreString)
        
        return TasksBundleScreenTaskCell.Model(
            title: task.title,
            score: score,
            isEnabled: score == nil
        )
    }
    
    private func makeScoreString(score: Float) -> (String, UIColor) {
        let color: UIColor = {
            switch score {
            case ..<(0.4):
                return .red
            case (0.4)..<0.75:
                return .orange
            default:
                return .green
            }
        }()
        
        return ("\(score * 100)%", color)
    }
    
    private func makeScoreString(score: Bool) -> (String, UIColor) {
        (score ? "Разгадано" : "Провалено", score ? .green : .red)
    }
    
}

