//
//  AttachmentsView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04.12.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit

public protocol AttachmentsViewDelegate: AnyObject {
    func numberOfAttachments(in view: AttachmentsView) -> Int
    func attachment(at index: Int, in view: AttachmentsView) -> Any?
    func didSelectAttachment(at index: Int, in view: AttachmentsView)
}

public final class AttachmentsView: UIView {
    
    // MARK: - External dependencies
    
    private unowned let delegate: AttachmentsViewDelegate
    
    // MARK: - Subviews
    
    private let listLayout = UICollectionViewFlowLayout()
    
    public lazy var listView = AutosizingCollectionView(
        frame: .zero,
        collectionViewLayout: listLayout
    )
    
    // MARK: - Init
    
    public init(delegate: AttachmentsViewDelegate) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        setup()
        setupListView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Public functions
    
    public func reloadData() {
        listView.reloadData()
        isHidden = delegate.numberOfAttachments(in: self) == 0
    }
    
    // MARK: - Setup
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupListView() {
        addSubview(listView)
        
        listView.delegate = self
        listView.dataSource = self
        listView.backgroundColor = nil
        listView.showsVerticalScrollIndicator = false
        
        listView.registerEmptyCell()
        listView.register(PhotoAttachmentCell.self, forCellWithReuseIdentifier: PhotoAttachmentCell.identifier)
        listView.register(AudioAttachmentCell.self, forCellWithReuseIdentifier: AudioAttachmentCell.identifier)
        
        listView.register(
            ListSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ListSectionHeaderView.identifier
        )
        
        listView.pin(to: self)
    }
    
}

extension AttachmentsView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        delegate.numberOfAttachments(in: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = delegate.attachment(at: indexPath.item, in: self) else {
            return collectionView.dequeueEmptyCell(for: indexPath)
        }
        
        if let photoAttachment = model as? PhotoAttachmentCell.Model {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoAttachmentCell.identifier,
                for: indexPath
            ) as! PhotoAttachmentCell
            
            cell.configure(model: photoAttachment)
            cell.onTapPhoto = { [unowned delegate] in
                delegate.didSelectAttachment(at: indexPath.item, in: self)
            }
            
            return cell
        } else if let audioAttachment = model as? AudioAttachmentCell.Model {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AudioAttachmentCell.identifier,
                for: indexPath
            ) as! AudioAttachmentCell
            
            cell.configure(model: audioAttachment)
            
            return cell
        } else {
            return collectionView.dequeueEmptyCell(for: indexPath)
        }
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
        
        view.configure(title: "Дополнения") // TODO
        
        view.layoutMargins = .zero
        view.titleLabel.font = .heading2
        view.titleLabel.textAlignment = .center
        
        return view
    }
    
}

extension AttachmentsView: UICollectionViewDelegate {}

extension AttachmentsView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        guard self.collectionView(collectionView, numberOfItemsInSection: section) > 0 else { return .zero }
        
        return UIEdgeInsets(top: section == 0 ? 0 : 20, left: 0, bottom: 20, right: 0)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard
            self.collectionView(collectionView, numberOfItemsInSection: section) > 0
        else { return .zero }
        
        return CGSize(width: collectionView.bounds.width, height: 52)
    }
    
}
