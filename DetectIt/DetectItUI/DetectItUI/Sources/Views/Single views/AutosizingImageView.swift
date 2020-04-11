//
//  AutosizingImageView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 11/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public class AutosizingImageView: UIImageView {
    
    public override var bounds: CGRect {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var image: UIImage? {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    public override var intrinsicContentSize: CGSize {
        guard let image = image, let superview = superview else {
            return .zero
        }
        
        if image.size.width > image.size.height {
            let ratio = superview.bounds.size.height / image.size.height
            let scaledWidth = image.size.width * ratio

            return CGSize(width: scaledWidth, height: superview.bounds.size.height)
        } else {
            let ratio = superview.bounds.size.width / image.size.width
            let scaledHeight = image.size.height * ratio

            return CGSize(width: superview.bounds.size.width, height: scaledHeight)
        }
    }

}
