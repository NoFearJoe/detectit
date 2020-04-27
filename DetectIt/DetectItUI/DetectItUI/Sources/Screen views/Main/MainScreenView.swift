//
//  MainScreenView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public protocol MainScreenViewDelegate: AnyObject {
    func header() -> MainScreenHeaderView.Model
    
    func numberOfFeedItems() -> Int
    func feedItem(at index: Int) -> Any?
    func tasksBundleShallowModel(at index: Int) -> TasksBundleCell.ShallowModel?
    func didSelectFeedItem(at index: Int)
    func didTapBuyTasksBundleButton(at index: Int)
    
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
    
    private let prototypeTaskCell = MainScreenTaskCell()
    
    // MARK: - External dependencies
    
    private unowned let delegate: MainScreenViewDelegate
    
    // MARK: - Init
    
    public init(delegate: MainScreenViewDelegate) {
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
    
    public func shallowReloadData() {
        contentView.visibleCells.forEach { cell in
            guard let indexPath = contentView.indexPath(for: cell), indexPath.section == 0 else { return }
            guard let shallowModel = delegate.tasksBundleShallowModel(at: indexPath.item) else { return }
            guard let cell = cell as? TasksBundleCell else { return }
            
            cell.configure(model: shallowModel)
        }
    }
    
    public func reloadHeader() {
        guard
            let header = contentView.supplementaryView(
                forElementKind: UICollectionView.elementKindSectionHeader,
                at: IndexPath(item: 0, section: 0)
            ) as? MainScreenHeaderView
        else { return }
        
        header.configure(model: delegate.header())
    }
    
    // MARK: - Setup
    
    private func setup() {
        backgroundColor = .black
    }
    
    private func setupContentView() {
        addSubview(contentView)
        
        contentView.pin(to: self)
        
        contentView.delegate = self
        contentView.dataSource = self
        contentView.backgroundColor = nil
        contentView.delaysContentTouches = false
        contentView.showsVerticalScrollIndicator = false
        contentView.contentInset = UIEdgeInsets(
            top: 48, left: 20, bottom: 20, right: 20
        )
        
        contentView.registerEmptyCell()
        contentView.register(
            TasksBundleCell.self,
            forCellWithReuseIdentifier: TasksBundleCell.identifier
        )
        contentView.register(
            MainScreenTaskCell.self,
            forCellWithReuseIdentifier: MainScreenTaskCell.identifier
        )
        contentView.register(
            MainScreenActionCell.self,
            forCellWithReuseIdentifier: MainScreenActionCell.identifier
        )
        contentView.register(
            MainScreenHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MainScreenHeaderView.identifier
        )
    }
    
}

// MARK: - UICollectionViewDataSource

extension MainScreenView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if section == 0 {
            return delegate.numberOfFeedItems()
        } else {
            return delegate.numberOfActions()
        }
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let item = delegate.feedItem(at: indexPath.item) else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
            
            if let tasksBundleModel = item as? TasksBundleCell.Model {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TasksBundleCell.identifier,
                    for: indexPath
                ) as! TasksBundleCell
                
                cell.configure(model: tasksBundleModel)
                
                if let shallowModel = delegate.tasksBundleShallowModel(at: indexPath.item) {
                    cell.configure(model: shallowModel)
                }
                
                cell.onTapPlayButton = { [unowned self] in
                    self.delegate.didSelectFeedItem(at: indexPath.item)
                }
                
                cell.onTapBuyButton = {
                    self.delegate.didTapBuyTasksBundleButton(at: indexPath.item)
                }
                
                return cell
            } else if let profileTaskModel = item as? MainScreenTaskCell.Model {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MainScreenTaskCell.identifier,
                    for: indexPath
                ) as! MainScreenTaskCell
                
                cell.configure(model: profileTaskModel)
                
                return cell
            } else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
        } else {
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
        
        header.configure(model: delegate.header())
        
        return header
    }
    
}

// MARK: - UICollectionViewDelegate

extension MainScreenView: UICollectionViewDelegate {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if indexPath.section == 0 {
            delegate.didSelectFeedItem(at: indexPath.item)
        } else {
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
        if section == 0 {
            return 20
        } else {
            return 8
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
        if section == 0 {
            return UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        } else {
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
                    - 20

                return width * 0.5
            } else {
                return collectionView.bounds.width
                    - collectionView.contentInset.left
                    - collectionView.contentInset.right
            }
        }()

        if indexPath.section == 0 {
            if let taskModel = delegate.feedItem(at: indexPath.item) as? MainScreenTaskCell.Model {
                if taskModel.backgroundImageURL != nil {
                    return CGSize(width: width, height: width * 0.75)
                } else {
                    return prototypeTaskCell.calculateSize(model: taskModel, width: width)
                }
            } else {
                return CGSize(width: width, height: width * 1.25)
            }
        } else {
            return CGSize(width: width, height: 40)
        }
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if section == 0 {
            let width: CGFloat = {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let width = collectionView.bounds.width
                        - collectionView.contentInset.left
                        - collectionView.contentInset.right
                        - 20
                    
                    return width * 0.5
                } else {
                    return collectionView.bounds.width
                        - collectionView.contentInset.left
                        - collectionView.contentInset.right
                }
            }()
            
            return MainScreenHeaderView.prototype.size(model: delegate.header(), width: width)
        } else {
            return .zero
        }
    }
    
}
