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
        
        let ratio = superview.bounds.size.width / image.size.width

        return CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
    }

}
