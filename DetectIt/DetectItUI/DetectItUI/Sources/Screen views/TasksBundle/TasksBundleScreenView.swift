//
//  TasksBundleScreenView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public protocol TasksBundleScreenViewDelegate: AnyObject {
    func didTapCloseButton()
    
    func numberOfSections() -> Int
    func numberOfTasks(in section: Int) -> Int
    func sectionHeader(for section: Int) -> String?
    func task(at index: Int, in section: Int) -> TasksBundleScreenTaskCell.Model?
    func didSelectTask(at index: Int, in section: Int)
}

public final class TasksBundleScreenView: UIView {
    
    // MARK: - Subviews
    
    private let closeButton = SolidButton.closeButton()
    public let headerView = TasksBundleScreenHeaderView()
    private let contentView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private lazy var headerVisibilityManager = FloatingViewVisibilityManager(
        floatingView: headerView,
        scrollView: contentView
    )
    
    // MARK: - Init
    
    private unowned let delegate: TasksBundleScreenViewDelegate
    
    public init(delegate: TasksBundleScreenViewDelegate) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        setup()
        setupViews()
        
        headerVisibilityManager.setEnabled(true)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public func configureHeader(model: TasksBundleScreenHeaderView.Model) {
        headerView.configure(model: model)
    }
    
    public func reloadContent() {
        contentView.reloadData()
    }
    
    // MARK: - Overrides
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.contentInset.bottom = safeAreaInsets.bottom
    }
    
    // MARK: - Actions
    
    @objc private func didTapCloseButton() {
        delegate.didTapCloseButton()
    }
    
    // MARK: - Setup
    
    private func setup() {
        backgroundColor = .black
    }
    
    private func setupViews() {
        addSubview(contentView)
        
        contentView.pin(to: self)
        
        contentView.delegate = self
        contentView.dataSource = self
        contentView.backgroundColor = nil
        contentView.delaysContentTouches = false
        contentView.showsVerticalScrollIndicator = false
        contentView.contentInsetAdjustmentBehavior = .never
        
        contentView.register(
            TasksBundleScreenTaskCell.self,
            forCellWithReuseIdentifier: TasksBundleScreenTaskCell.identifier
        )
        contentView.register(
            ListSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ListSectionHeaderView.identifier
        )
        
        addSubview(headerView)
        
        headerView.onChangeHeight = { [unowned self] height in
            self.contentView.contentInset.top = height
        }
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
}

extension TasksBundleScreenView: UICollectionViewDataSource {
    
    public func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        delegate.numberOfSections()
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        delegate.numberOfTasks(in: section)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TasksBundleScreenTaskCell.identifier,
            for: indexPath
        ) as! TasksBundleScreenTaskCell
        
        if let model = delegate.task(at: indexPath.item, in: indexPath.section) {
            cell.configure(model: model)
        }
        
        return cell
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ListSectionHeaderView.identifier,
            for: indexPath
        ) as! ListSectionHeaderView
        
        if let title = delegate.sectionHeader(for: indexPath.section) {
            view.configure(title: title)
        }
        
        return view
    }
    
}

extension TasksBundleScreenView: UICollectionViewDelegate {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        delegate.didSelectTask(at: indexPath.item, in: indexPath.section)
    }
    
}

extension TasksBundleScreenView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 64)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 48)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
    
}
