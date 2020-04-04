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
            sections.append((.audiorecords, []))
        }
        
        if !bundle.extraEvidenceTasks.isEmpty {
            sections.append((.extraEvidences, []))
        }
        
        if !bundle.decoderTasks.isEmpty {
            sections.append((.ciphers, [
                TasksBundleScreenTaskCell.Model(icon: UIImage.asset(named: "Test")!, title: "Тест 1", score: "100%", isEnabled: true),
                TasksBundleScreenTaskCell.Model(icon: UIImage.asset(named: "Test")!, title: "Тест 2", score: nil, isEnabled: true),
                TasksBundleScreenTaskCell.Model(icon: UIImage.asset(named: "Test")!, title: "Тест 1", score: "100%", isEnabled: false),
                TasksBundleScreenTaskCell.Model(icon: UIImage.asset(named: "Test")!, title: "Тест 2", score: nil, isEnabled: true),
                TasksBundleScreenTaskCell.Model(icon: UIImage.asset(named: "Test")!, title: "Тест 1", score: "100%", isEnabled: false),
                TasksBundleScreenTaskCell.Model(icon: UIImage.asset(named: "Test")!, title: "Тест 2", score: nil, isEnabled: true),
                TasksBundleScreenTaskCell.Model(icon: UIImage.asset(named: "Test")!, title: "Тест 1", score: "100%", isEnabled: false),
                TasksBundleScreenTaskCell.Model(icon: UIImage.asset(named: "Test")!, title: "Тест 2", score: nil, isEnabled: true),
                TasksBundleScreenTaskCell.Model(icon: UIImage.asset(named: "Test")!, title: "Тест 1", score: "100%", isEnabled: false),
                TasksBundleScreenTaskCell.Model(icon: UIImage.asset(named: "Test")!, title: "Тест 2", score: nil, isEnabled: true)
            ]))
        }
        
        if !bundle.profileTasks.isEmpty {
            sections.append((.profiles, []))
        }
        
        if !bundle.questTasks.isEmpty {
            sections.append((.quests, []))
        }
        
        return sections
    }
    
}

