//
//  UIImageView+ImageLoader.swift
//  DetectItUI
//
//  Created by Илья Харабет on 03/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

public extension UIImageView {
    
    func loadImage(_ source: ImageSource, postprocessing: ((UIImage) -> UIImage)? = nil, completion: ((UIImage?) -> Void)? = nil) {
        ImageLoader.share.load(source, postprocessing: postprocessing) { [weak self] image in
            guard let self = self else { return }
            
            UIView.transition(
                with: self,
                duration: 0.25,
                options: .transitionCrossDissolve,
                animations: {
                    self.image = image
                },
                completion: nil
            )
            
            completion?(image)
        }
    }
    
}
