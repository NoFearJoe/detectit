//
//  QuestTaskScreenView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 19.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public protocol QuestTaskScreenViewDelegate: AnyObject {    
    func didSelectRoute(chapterIndex: Int, answerIndex: Int)
}

public final class QuestTaskScreenView: NSObject {
    
    public let prepositionView = ProfilePrepositionCell(frame: .zero)
    
    public let chaptersContainerView = UIStackView()
    
    public let scoreLabel = UILabel()
    
    public let endingTitleView = ListSectionHeaderView()
    public let endingTextLabel = UILabel()
    
    private let delegate: QuestTaskScreenViewDelegate
    
    public init(delegate: QuestTaskScreenViewDelegate) {
        self.delegate = delegate
        
        super.init()
    }
    
    // MARK: - Reloading
    
    public func setPreposition(_ preposition: ProfilePrepositionCell.Model) {
        prepositionView.configure(model: preposition)
    }
    
    public func setChapters(_ chapters: [QuestTaskChapterView.Model]) {
        chaptersContainerView.arrangedSubviews.forEach {
            chaptersContainerView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        chapters.enumerated().forEach { index, chapter in
            let view = makeChapterView(model: chapter, index: index)
            chaptersContainerView.addArrangedSubview(view)
        }
    }
    
    public func appendChapter(_ chapter: QuestTaskChapterView.Model) {
        let view = makeChapterView(model: chapter, index: chaptersContainerView.arrangedSubviews.count)
        
        chaptersContainerView.addArrangedSubview(view)
        
        view.alpha = 0
        view.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            view.alpha = 1
        }
    }
    
    public func updateChapter(_ chapter: QuestTaskChapterView.Model, at index: Int) {
        guard let chapterView = chaptersContainerView.arrangedSubviews[index] as? QuestTaskChapterView else { return }
        
        chapterView.configure(model: chapter)
    }
    
    private func makeChapterView(model: QuestTaskChapterView.Model, index: Int) -> QuestTaskChapterView {
        let view = QuestTaskChapterView()
        view.configure(model: model)
        view.onSelectAction = { [unowned self] routeIndex in
            self.delegate.didSelectRoute(chapterIndex: index, answerIndex: routeIndex)
        }
        return view
    }
    
    // MARK: - Setup
    
    public func setupViews() {
        // Chapters
        
        chaptersContainerView.axis = .vertical
        chaptersContainerView.spacing = 20
        
        // Score
        
        scoreLabel.font = .score1
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center
        
        // Crime description
        
        endingTitleView.titleLabel.textAlignment = .center
        endingTitleView.configure(title: "quest_task_screen_ending_title".localized)
        endingTitleView.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        endingTextLabel.font = .text3
        endingTextLabel.textColor = .white
        endingTextLabel.numberOfLines = 0
    }
    
}
