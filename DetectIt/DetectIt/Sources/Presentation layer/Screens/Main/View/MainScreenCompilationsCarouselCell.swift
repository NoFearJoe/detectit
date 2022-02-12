//
//  MainScreenCompilationsCarouselCell.swift
//  DetectIt
//
//  Created by Илья Харабет on 31.01.2022.
//  Copyright © 2022 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

public final class MainScreenCompilationsCarouselCell: UICollectionViewCell {
    
    public static let identifier = "MainScreenCompilationsCarouselCell"
    
    private var compilations: [MainScreenCompilationCell.Model] = []
    private var onSelectCell: ((Int) -> Void)?
    
    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        return l
    }()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(collectionView)
        collectionView.pin(to: contentView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = nil
        collectionView.alwaysBounceHorizontal = true
        collectionView.delaysContentTouches = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(
            top: 0, left: 20, bottom: 0, right: 20
        )
        
        collectionView.register(
            MainScreenCompilationCell.self,
            forCellWithReuseIdentifier: MainScreenCompilationCell.identifier
        )
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public func configure(
        compilations: [MainScreenCompilationCell.Model],
        onSelectCell: ((Int) -> Void)?
    ) {
        self.compilations = compilations
        self.onSelectCell = onSelectCell
        
        collectionView.reloadData()
    }
    
}

extension MainScreenCompilationsCarouselCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        compilations.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MainScreenCompilationCell.identifier,
            for: indexPath
        ) as! MainScreenCompilationCell
        
        cell.configure(model: compilations[indexPath.item])
        
        return cell
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        onSelectCell?(indexPath.item)
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
        
        return CGSize(width: width * 0.75, height: collectionView.bounds.height)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        12
    }
    
}
