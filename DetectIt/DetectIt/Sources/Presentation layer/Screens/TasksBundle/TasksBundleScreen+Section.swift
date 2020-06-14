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
        case ciphers
        case profiles
        case quests
        
        var title: String {
            switch self {
            case .ciphers:
                return "tasks_bundle_screen_ciphers_section_title".localized
            case .profiles:
                return "tasks_bundle_screen_profiles_section_title".localized
            case .quests:
                return "tasks_bundle_screen_quests_section_title".localized
            }
        }
        
    }
    
    typealias SectionModel = (Section, [TasksBundleScreenTaskCell.Model])
    
    func makeSections(bundle: TasksBundle) -> [SectionModel] {
        var sections: [SectionModel] = []
        
        if !bundle.decoderTasks.isEmpty {
            sections.append(
                (.ciphers, bundle.decoderTasks.map { map(task: $0, scores: bundle.taskScores, bundleID: bundle.info.id) })
            )
        }
        
        if !bundle.profileTasks.isEmpty {
            sections.append(
                (.profiles, bundle.profileTasks.map { map(task: $0, scores: bundle.taskScores, bundleID: bundle.info.id) })
            )
        }
        
        if !bundle.questTasks.isEmpty {
            sections.append(
                (.quests, bundle.questTasks.map { map(task: $0, scores: bundle.taskScores, bundleID: bundle.info.id) })
            )
        }
        
        return sections
    }
    
    private func map(task: Task & TaskScoring, scores: [TasksBundle.TaskScore]?, bundleID: String) -> TasksBundleScreenTaskCell.Model {
        let score = scores?.first(where: { $0.taskID == task.id })?.score ?? TaskScore.get(id: task.id, taskKind: task.kind, bundleID: bundleID)
        let scoreString = makeScoreString(score: score, max: task.maxScore)
        let isLocked = !FullVersionManager.hasBought && task.taskDifficulty.rawValue >= 3
        
        return TasksBundleScreenTaskCell.Model(
            icon: isLocked ? UIImage.asset(named: "lock")?.withTintColor(.yellow, renderingMode: .alwaysOriginal) : nil,
            title: task.title,
            score: scoreString,
            difficultyImage: task.taskDifficulty.icon,
            isEnabled: true,
            isDone: score != nil,
            isLocked: isLocked
        )
    }
    
    private func makeScoreString(score: Int?, max: Int) -> (String, UIColor) {
        let color = UIColor.score(value: score, max: max)
        
        return (ScoreStringBuilder.makeScoreString(score: score, max: max), color)
    }
    
}

