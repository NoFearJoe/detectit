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
    
    private let placeholderView = ScreenPlaceholderView(isInitiallyHidden: true)
    
    // MARK: - Init
    
    private let tasksBundle: TasksBundle.Info
    private let tasksBundleImage: UIImage
    
    init(tasksBundle: TasksBundle.Info, image: UIImage) {
        self.tasksBundle = tasksBundle
        self.tasksBundleImage = image
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - State
    
    private var bundle: TasksBundle?
    
    private var sections: [SectionModel] = []
    
    // MARK: - Overrides
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }
    
    override func loadView() {
        view = TasksBundleScreenView(delegate: self)
        
        setupPlaceholder()
    }
    
    override func prepare() {
        super.prepare()
    }
    
    override func refresh() {
        super.refresh()
        
        guard bundle == nil else {
            reloadHeader(bundle: bundle!)
            reloadContent(bundle: bundle!)
            
            return
        }
        
        placeholderView.setVisible(true, animated: false)
        
        TasksBundle.load(bundleID: tasksBundle.id) { [weak self] bundle in
            guard let self = self else { return }
            
            self.bundle = bundle
            
            if let bundle = bundle {
                self.reloadHeader(bundle: bundle)
                self.reloadContent(bundle: bundle)
                
                self.placeholderView.setVisible(false, animated: true)
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
        guard let bundle = bundle else { return }
        
        let section = sections[section].0
        
        let screen: Screen = {
            switch section {
            case .extraEvidences:
                return ExtraEvidenceTaskScreen(
                    task: bundle.extraEvidenceTasks[index],
                    bundle: bundle
                )
            case .ciphers:
                return DecoderTaskScreen(
                    task: bundle.decoderTasks[index],
                    bundle: bundle
                )
            case .profiles:
                return ProfileTaskScreen(
                    task: bundle.profileTasks[index],
                    bundle: bundle
                )
            case .quests:
                return QuestTaskScreen(
                    task: bundle.questTasks[index],
                    bundle: bundle
                )
            }
        }()
        
        screen.modalPresentationStyle = .fullScreen
        screen.modalTransitionStyle = .crossDissolve
        
        present(screen, animated: true, completion: nil)
    }
    
}

private extension TasksBundleScreen {
    
    func setupPlaceholder() {
        view.addSubview(placeholderView)
        placeholderView.pin(to: view)
    }
    
    func reloadHeader(bundle: TasksBundle) {
        let score = TaskScore.get(bundleID: bundle.info.id) ?? 0
        let totalScore = "\(score)/\(bundle.maxScore)"
        
        self.screenView.configureHeader(
            model: TasksBundleScreenHeaderView.Model(
                image: self.tasksBundleImage,
                title: self.tasksBundle.title,
                totalScore: totalScore,
                description: self.tasksBundle.description,
                price: nil // TODO
            )
        )
    }
    
    func reloadContent(bundle: TasksBundle) {
        sections = self.makeSections(bundle: bundle)
        screenView.reloadContent()
    }
    
}
