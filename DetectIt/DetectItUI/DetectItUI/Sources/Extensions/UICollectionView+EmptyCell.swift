//
//  UICollectionView+EmptyCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 11/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension UICollectionView {
    
    func registerEmptyCell() {
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Empty")
    }
    
    func dequeueEmptyCell(for indexPath: IndexPath) -> UICollectionViewCell {
        assertionFailure("Что-то пошло не так")
        
        return dequeueReusableCell(withReuseIdentifier: "Empty", for: indexPath)
    }
    
}
