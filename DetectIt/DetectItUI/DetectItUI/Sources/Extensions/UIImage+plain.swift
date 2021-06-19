//
//  UIImage+plain.swift
//  DetectItUI
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension UIImage {
    
    /// Создает одноцветное изображение заданного размера. Чаще нужно для создания изображений для свойств shadowImage, backgroundImage у различных панелей.
    ///
    /// - Parameter color: Цвет изображения
    /// - Parameter size: Размер изображение. По-умолчанию 1х1
    ///
    /// - Returns: Изображение или nil в случае неудачи
    class func plain(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContext(rect.size)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func plainRounded(color: UIColor, size: CGSize = CGSize(width: 1, height: 1), cornerRadius: CGFloat) -> UIImage? {
        let scale = UIScreen.main.scale
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        let rect = CGRect(origin: .zero, size: scaledSize)
        
        let cornerRadius = cornerRadius * scale
        
        UIGraphicsBeginImageContext(rect.size)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(color.cgColor)

        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
