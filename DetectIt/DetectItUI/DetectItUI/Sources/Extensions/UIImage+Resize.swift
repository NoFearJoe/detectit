//
//  UIImage+Resize.swift
//  DetectItUI
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension UIImage {
    
    func resized(to size: CGSize, preserveAspectRatio: Bool = true) -> UIImage {
        let screenScale = UIScreen.main.scale
        var targetSize = size
        
        if preserveAspectRatio {
            let ratioX = size.width / self.size.width
            let ratioY = size.height / self.size.height
            let ratio = ratioX < ratioY ? ratioX : ratioY
            targetSize = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)
        }
        
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = screenScale
        format.opaque = isOpaque
        
        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            if scale != screenScale {
                let scaleMultiplier = screenScale / scale
                let scaledSize = CGSize(width: targetSize.width * scaleMultiplier, height: targetSize.height * scaleMultiplier)
                let scaledImage = UIGraphicsImageRenderer(size: scaledSize, format: format).image { _ in
                    draw(in: CGRect(origin: .zero, size: scaledSize))
                }
                scaledImage.draw(in: CGRect(origin: .zero, size: targetSize))
            } else {
                draw(in: CGRect(origin: .zero, size: size))
            }
        }
    }
    
    func rotated(orientation: UIImage.Orientation) -> UIImage? {
        guard cgImage != nil || ciImage != nil else { return nil }
        
        let targetSize: CGSize
        switch orientation {
        case .left, .right, .leftMirrored, .rightMirrored:
            targetSize = CGSize(width: size.height, height: size.width)
        default:
            targetSize = size
        }
        
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        format.opaque = isOpaque
        
        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            var rotatedImage: UIImage?
            if let cgImage = cgImage {
                rotatedImage = UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
            } else if let ciImage = ciImage {
                rotatedImage = UIImage(ciImage: ciImage, scale: scale, orientation: orientation)
            }
            
            rotatedImage?.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    func rounded(radius: CGFloat, opaque: Bool = false, backgroundColor: CGColor? = nil) -> UIImage {
        let rect = CGRect(origin: .zero, size: self.size)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, opaque, UIScreen.main.scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }
        
        if let backgroundColor = backgroundColor {
            context.setFillColor(backgroundColor)
            context.fill(rect)
        }
        
        context.beginPath()
        context.saveGState()
        context.translateBy(x: rect.minX, y: rect.minY)
        context.scaleBy(x: radius, y: radius)
        
        let rectWidth = rect.width / radius
        let rectHeight = rect.height / radius
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: rectWidth, y: rectHeight / 2))
        path.addArc(tangent1End: CGPoint(x: rectWidth, y: rectHeight), tangent2End: CGPoint(x: rectWidth / 2, y: rectHeight), radius: 1)
        path.addArc(tangent1End: CGPoint(x: 0, y: rectHeight), tangent2End: CGPoint(x: 0, y: rectHeight / 2), radius: 1)
        path.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: rectWidth / 2, y: 0), radius: 1)
        path.addArc(tangent1End: CGPoint(x: rectWidth, y: 0), tangent2End: CGPoint(x: rectWidth, y: rectHeight / 2), radius: 1)
        context.addPath(path)
        context.restoreGState()
        context.closePath()
        context.clip()
        
        draw(in: rect)
        
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return roundedImage ?? self
    }
    
    private var isOpaque: Bool {
        guard let alphaInfo = cgImage?.alphaInfo else {
            return false
        }
        
        switch alphaInfo {
        case .first, .last, .premultipliedFirst, .premultipliedLast:
            return false
        default:
            return true
        }
        
    }
    
}
