//
//  TasksBundleScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class TasksBundleScreen: Screen {
    
    private var screenView: TasksBundleScreenView {
        view as! TasksBundleScreenView
    }
    
    // MARK: - Init
    
    private let tasksBundle: TasksBundles
    
    init(tasksBundle: TasksBundles) {
        self.tasksBundle = tasksBundle
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - State
    
    private var bundle: TasksBundle?
    
    private var sections: [SectionModel] = []
    
    // MARK: - Overrides
    
    override func loadView() {
        view = TasksBundleScreenView(delegate: self)
    }
    
    override func prepare() {
        super.prepare()
    }
    
    override func refresh() {
        super.refresh()
        
        screenView.configureHeader(
            model: TasksBundleScreenHeaderView.Model(
                image: tasksBundle.image,
                title: tasksBundle.title,
                description: tasksBundle.description,
                price: nil // TODO
            )
        )
        
        guard bundle == nil else { return }
        
        // TODO: Loader
        TasksBundle.load(bundleID: tasksBundle.rawValue) { [weak self] bundle in
            guard let self = self else { return }
            
            self.bundle = bundle
            
            if let bundle = bundle {
                self.sections = self.makeSections(bundle: bundle)
                self.screenView.reloadContent()
            }
        }
    }
    
}

// MARK: - TasksBundleScreenViewDelegate

extension TasksBundleScreen: TasksBundleScreenViewDelegate {
    
    func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections() -> Int {
        sections.count
    }
    
    func numberOfTasks(in section: Int) -> Int {
        sections[section].1.count
    }
    
    func sectionHeader(for section: Int) -> String? {
        sections[section].0.title
    }
    
    func task(at index: Int, in section: Int) -> TasksBundleScreenTaskCell.Model? {
        sections[section].1[index]
    }
    
    func didSelectTask(at index: Int, in section: Int) {
        
    }
    
}

// MARK: - Utils

private extension TasksBundleScreen {
    
    enum Section {
        case audiofiles
        case extraEvidences
        case ciphers
        case profiles
        case quests
        
        var title: String {
            switch self {
            case .audiofiles:
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
            sections.append((.audiofiles, []))
        }
        
        if !bundle.extraEvidenceTasks.isEmpty {
            sections.append((.extraEvidences, []))
        }
        
        if !bundle.decoderTasks.isEmpty {
            sections.append((.ciphers, [
                TasksBundleScreenTaskCell.Model(icon: UIImage.asset(named: "Test")!, title: "Тест 1", score: "100%", isEnabled: false),
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
