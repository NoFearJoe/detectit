//
//  MainScreenView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

public protocol MainScreenViewDelegate: AnyObject {
    func header() -> MainScreenHeaderView.Model?
    func didTapProfileButton()
    
    func filters() -> [MainScreenFiltersView.Model]
    func didSelectFilter(at index: Int)
    
    func banner() -> MainScreenBannerCell.Model?
    func didSelectBanner()
    func didCloseBanner()
    
    func shouldShowCompletedTasksCell() -> Bool
    func didSelectCompletedTasksCell()
    
    func numberOfFeedItems() -> Int
    func feedItem(at index: Int) -> Any?
    func didSelectFeedItem(at index: Int)
    
    func numberOfActions() -> Int
    func action(at index: Int) -> String?
    func didSelectAction(at index: Int)
}

public final class MainScreenView: UIView {
    
    // MARK: - Subviews
    
    private let contentView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let prototypeBannerCell = MainScreenBannerCell()
    private let prototypeTaskCell = MainScreenTaskCell()
    private let prototypeActionCell = MainScreenActionCell()
    
    // MARK: - External dependencies
    
    private let sections: [Section]
    private unowned let delegate: MainScreenViewDelegate
    
    // MARK: - Init
    
    public init(sections: [Section], delegate: MainScreenViewDelegate) {
        self.sections = sections
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        setup()
        setupContentView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public func reloadData() {
        contentView.reloadData()
    }
    
    public func reloadHeader() {
        guard let model = delegate.header() else { return }
        
        header?.configure(model: model)
    }
    
    public func reloadFilters() {
        header?.configureFilters(models: delegate.filters())
    }
    
    public func reloadBanner() {
        contentView.reloadSections(IndexSet(integer: Section.banner.rawValue))
    }
    
    public func reloadCompletedTasksCell() {
        contentView.reloadSections(IndexSet(integer: Section.completedTasks.rawValue))
    }
    
    // MARK: - Setup
    
    private func setup() {
        backgroundColor = .systemBackground
    }
    
    private func setupContentView() {
        addSubview(contentView)
        
        contentView.pin(to: self)
        
        contentView.delegate = self
        contentView.dataSource = self
        contentView.backgroundColor = nil
        contentView.alwaysBounceVertical = true
        contentView.delaysContentTouches = false
        contentView.showsVerticalScrollIndicator = false
        contentView.contentInset = UIEdgeInsets(
            top: 48, left: 20, bottom: 20, right: 20
        )
        
        contentView.registerEmptyCell()
        contentView.register(
            MainScreenTasksBundleCell.self,
            forCellWithReuseIdentifier: MainScreenTasksBundleCell.identifier
        )
        contentView.register(
            MainScreenTaskCell.self,
            forCellWithReuseIdentifier: MainScreenTaskCell.identifier
        )
        contentView.register(
            MainScreenBannerCell.self,
            forCellWithReuseIdentifier: MainScreenBannerCell.identifier
        )
        contentView.register(
            MainScreenActionCell.self,
            forCellWithReuseIdentifier: MainScreenActionCell.identifier
        )
        contentView.register(
            MainScreenPlaceholderCell.self,
            forCellWithReuseIdentifier: MainScreenPlaceholderCell.identifier
        )
        contentView.register(
            MainScreenCompletedTasksCell.self,
            forCellWithReuseIdentifier: MainScreenCompletedTasksCell.identifier
        )
        contentView.register(
            MainScreenHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MainScreenHeaderView.identifier
        )
    }
    
    private var header: MainScreenHeaderView? {
        contentView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) as? MainScreenHeaderView
    }
    
}

// MARK: - UICollectionViewDataSource

extension MainScreenView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let section = Section(section)
        
        guard sections.contains(section) else { return 0 }
        
        switch section {
        case .banner:
            return delegate.banner() == nil ? 0 : 1
        case .completedTasks:
            return delegate.shouldShowCompletedTasksCell() ? 1 : 0
        case .tasks:
            return delegate.numberOfFeedItems()
        case .actions:
            return delegate.numberOfActions()
        }
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch Section(indexPath.section) {
        case .banner:
            guard let model = delegate.banner() else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MainScreenBannerCell.identifier,
                for: indexPath
            ) as! MainScreenBannerCell
            
            cell.configure(model: model)
            
            cell.onTapCloseButton = { [unowned self] in
                self.delegate.didCloseBanner()
            }
            
            return cell
        case .completedTasks:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: MainScreenCompletedTasksCell.identifier,
                for: indexPath
            )
        case .tasks:
            guard let item = delegate.feedItem(at: indexPath.item) else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
            
            if let tasksBundleModel = item as? MainScreenTasksBundleCell.Model {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MainScreenTasksBundleCell.identifier,
                    for: indexPath
                ) as! MainScreenTasksBundleCell
                
                cell.configure(model: tasksBundleModel)
                
                cell.onTapPlayButton = { [unowned self] in
                    self.delegate.didSelectFeedItem(at: indexPath.item)
                }
                
                return cell
            } else if let profileTaskModel = item as? MainScreenTaskCell.Model {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MainScreenTaskCell.identifier,
                    for: indexPath
                ) as! MainScreenTaskCell
                
                cell.configure(model: profileTaskModel)
                
                return cell
            } else if let placeholderModel = item as? MainScreenPlaceholderCell.Model {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MainScreenPlaceholderCell.identifier,
                    for: indexPath
                ) as! MainScreenPlaceholderCell
                
                cell.configure(model: placeholderModel)
                
                return cell
            } else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
        case .actions:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MainScreenActionCell.identifier,
                for: indexPath
            ) as! MainScreenActionCell
            
            if let model = delegate.action(at: indexPath.item) {
                cell.configure(title: model)
            }
            
            return cell
        }
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: MainScreenHeaderView.identifier,
            for: indexPath
        ) as! MainScreenHeaderView
        
        if let model = delegate.header() {
            header.configure(model: model)
        }
        header.configureFilters(models: delegate.filters())
        
        header.onTapProfileButton = delegate.didTapProfileButton
        header.onSelectFilter = delegate.didSelectFilter
        
        return header
    }
    
}

// MARK: - UICollectionViewDelegate

extension MainScreenView: UICollectionViewDelegate {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        switch Section(indexPath.section) {
        case .banner:
            delegate.didSelectBanner()
        case .completedTasks:
            delegate.didSelectCompletedTasksCell()
        case .tasks:
            delegate.didSelectFeedItem(at: indexPath.item)
        case .actions:
            delegate.didSelectAction(at: indexPath.item)
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainScreenView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        switch Section(section) {
        case .banner: return 0
        case .completedTasks: return 0
        case .tasks: return 20
        case .actions: return 8
        }
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        20
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        switch Section(section) {
        case .banner:
            guard delegate.banner() != nil else { return .zero }
            
            return UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        case .completedTasks:
            return .zero
        case .tasks:
            return UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        case .actions:
            return UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        }
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width: CGFloat = {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let width = collectionView.bounds.width
                    - collectionView.contentInset.left
                    - collectionView.contentInset.right

                return width * 0.75
            } else {
                return collectionView.bounds.width
                    - collectionView.contentInset.left
                    - collectionView.contentInset.right
            }
        }()
        
        switch Section(indexPath.section) {
        case .banner:
            guard let model = delegate.banner() else { return .zero }
            
            return prototypeBannerCell.calculateSize(model: model, width: width)
        case .completedTasks:
            return CGSize(width: width, height: 48)
        case .tasks:
            if let taskModel = delegate.feedItem(at: indexPath.item) as? MainScreenTaskCell.Model {
                if taskModel.backgroundImagePath != nil {
                    return CGSize(width: width, height: width * 0.75)
                } else {
                    return prototypeTaskCell.calculateSize(model: taskModel, width: width)
                }
            } else if delegate.feedItem(at: indexPath.item) is MainScreenTasksBundleCell.Model {
                return CGSize(width: width, height: width * 1.25)
            } else {
                return CGSize(width: width, height: 156)
            }
        case .actions:
            return prototypeActionCell.calculateSize(model: delegate.action(at: indexPath.item) ?? "", width: width)
        }
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 0, let model = delegate.header() {
            let width: CGFloat = {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let width = collectionView.bounds.width
                        - collectionView.contentInset.left
                        - collectionView.contentInset.right
                    
                    return width * 0.75
                } else {
                    return collectionView.bounds.width
                        - collectionView.contentInset.left
                        - collectionView.contentInset.right
                }
            }()
                        
            return MainScreenHeaderView.prototype.size(model: model, width: width)
        } else {
            return .zero
        }
    }
    
}

public extension MainScreenView {
    enum Section: Int, CaseIterable {
        case banner
        case completedTasks
        case tasks
        case actions
    }
}

extension MainScreenView.Section {
    init(_ section: Int) {
        self = MainScreenView.Section(rawValue: section) ?? .tasks
    }
}
