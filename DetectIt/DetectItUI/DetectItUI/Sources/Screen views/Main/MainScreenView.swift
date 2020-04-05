//
//  MainScreenView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public protocol MainScreenViewDelegate: AnyObject {
    func numberOfTaskBundles() -> Int
    func tasksBundle(at index: Int) -> TasksBundleCell.Model?
    func tasksBundleShallowModel(at index: Int) -> TasksBundleCell.ShallowModel?
    func didSelectTasksBundle(at index: Int)
    func didTapBuyTasksBundleButton(at index: Int)
}

public final class MainScreenView: UIView {
    
    // MARK: - Subviews
    
    private let contentView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
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
            guard let indexPath = contentView.indexPath(for: cell) else { return }
            guard let shallowModel = delegate.tasksBundleShallowModel(at: indexPath.item) else { return }
            guard let cell = cell as? TasksBundleCell else { return }
            
            cell.configure(model: shallowModel)
        }
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
            top: 20, left: 20, bottom: 20, right: 20
        )
        
        contentView.register(
            TasksBundleCell.self,
            forCellWithReuseIdentifier: TasksBundleCell.identifier
        )
    }
    
}

// MARK: - UICollectionViewDataSource

extension MainScreenView: UICollectionViewDataSource {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        delegate.numberOfTaskBundles()
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TasksBundleCell.identifier,
            for: indexPath
        ) as! TasksBundleCell
        
        if let model = delegate.tasksBundle(at: indexPath.item) {
            cell.configure(model: model)
        }
        
        if let shallowModel = delegate.tasksBundleShallowModel(at: indexPath.item) {
            cell.configure(model: shallowModel)
        }
        
        cell.onTapPlayButton = { [unowned self] in
            self.delegate.didSelectTasksBundle(at: indexPath.item)
        }
        
        cell.onTapBuyButton = {
            self.delegate.didTapBuyTasksBundleButton(at: indexPath.item)
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension MainScreenView: UICollectionViewDelegate {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        delegate.didSelectTasksBundle(at: indexPath.item)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainScreenView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        20
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
        
        let ratio = CGFloat(1.25)
        
        return CGSize(width: width, height: width * ratio)
    }
    
}
