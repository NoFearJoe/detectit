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
    
    func loadImage(_ source: ImageSource, postprocessing: ((UIImage) -> UIImage)? = nil, completion: ((UIImage?, Bool, TimeInterval) -> Void)? = nil) {
        ImageLoader.share.load(source, postprocessing: postprocessing) { [weak self] image, cached in
            guard let self = self else { return }
            
            if cached {
                self.image = image
                
                completion?(image, cached, 0)
            } else {
                UIView.transition(
                    with: self,
                    duration: 0.25,
                    options: .transitionCrossDissolve,
                    animations: {
                        self.image = image
                    },
                    completion: nil
                )
                completion?(image, cached, 0.25)
            }
        }
    }
    
}
