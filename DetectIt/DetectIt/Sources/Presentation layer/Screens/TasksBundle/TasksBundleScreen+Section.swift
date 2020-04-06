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
                (.audiorecords, bundle.audiorecordTasks.map { map(task: $0, bundleID: bundle.info.id) })
            )
        }
        
        if !bundle.extraEvidenceTasks.isEmpty {
            sections.append(
                (.extraEvidences, bundle.extraEvidenceTasks.map { map(task: $0, bundleID: bundle.info.id) })
            )
        }
        
        if !bundle.decoderTasks.isEmpty {
            sections.append(
                (.ciphers, bundle.decoderTasks.map { map(task: $0, bundleID: bundle.info.id) })
            )
        }
        
        if !bundle.profileTasks.isEmpty {
            sections.append(
                (.profiles, bundle.profileTasks.map { map(task: $0, bundleID: bundle.info.id) })
            )
        }
        
        if !bundle.questTasks.isEmpty {
            sections.append(
                (.quests, bundle.questTasks.map { map(task: $0, bundleID: bundle.info.id) })
            )
        }
        
        return sections
    }
    
    private func map(task: Task & TaskScoring, bundleID: String) -> TasksBundleScreenTaskCell.Model {
        let score = TaskScore.get(id: task.id, taskKind: task.kind, bundleID: bundleID)
        let scoreString = makeScoreString(score: score, max: task.maxScore)
        
        return TasksBundleScreenTaskCell.Model(
            title: task.title,
            score: scoreString,
            difficultyImage: task.taskDifficulty.icon,
            isEnabled: score == nil
        )
    }
    
    private func makeScoreString(score: Int?, max: Int) -> (String, UIColor) {
        let score = score ?? 0
        
        let color: UIColor = {
            switch Float(score) / Float(max) {
            case ...0:
                return .lightGray
            case (0.0)..<(0.4):
                return .red
            case (0.4)..<0.75:
                return .orange
            default:
                return .green
            }
        }()
        
        return ("\(score)/\(max)", color)
    }
    
}

