//
//  UIImage+Filters.swift
//  DetectItUI
//
//  Created by Илья Харабет on 28/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension UIImage {
    
    func applyingOldPhotoFilter() -> UIImage {
        applying(filters: [
//            ("CICrop", ["inputRectangle": CIVector(cgRect: cropRect(ratio: CGSize(width: 15, height: 10)))]),
            ("CIColorPosterize", ["inputLevels": NSNumber(value: 20)]),
            ("CIPhotoEffectMono", [:]),
            ("CIVignette", ["inputIntensity": NSNumber(value: 2)])
        ])
    }
    
}

public extension UIImage {
    
    func applying(filters: [(String, [String: Any])]) -> UIImage {
        guard var resultCIImage = CIImage(image: self) else { return self }
                
        filters.forEach {
            resultCIImage = resultCIImage.applyingFilter($0.0, parameters: $0.1)
        }
                
        guard let resultCGImage = CIContext().createCGImage(resultCIImage, from: resultCIImage.extent) else {
            return self
        }
                
        return UIImage(cgImage: resultCGImage, scale: scale, orientation: imageOrientation)
    }
    
}

public extension UIImage {
    
    func cropRect(ratio: CGSize) -> CGRect {
        let width = size.width * scale
        let height = size.height * scale
        
        let scale = min(width / ratio.width, height / ratio.height)
        
        let targetSize = CGSize(width: ratio.width * scale, height: ratio.height * scale)
        
        return CGRect(origin: CGPoint(x: (width - targetSize.width) / 2, y: (height - targetSize.height) / 2), size: targetSize)
    }
    
}
