//
//  SplashScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 23.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

final class SplashScreen: Screen {
    
    private let imageView = UIImageView(image: UIImage(named: "LaunchIcon"))
    
    override func prepare() {
        super.prepare()
        
        view.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 96),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
}
