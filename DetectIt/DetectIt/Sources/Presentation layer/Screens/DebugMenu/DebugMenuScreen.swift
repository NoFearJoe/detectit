//
//  DebugMenuScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 13/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class DebugMenuScreen: Screen {
    
    private let contentController = StackViewController()
    
    private let clearScoreButton = SolidButton.primaryButton()
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .black
        
        contentController.place(into: self)
        
        contentController.stackView.layoutMargins = UIEdgeInsets(top: 40, left: 15, bottom: 40, right: 15)
        
        contentController.appendChild(clearScoreButton)
        
        setupViews()
    }
    
    @objc private func didTapClearScoreButton() {
        TaskScore.clear()
        TaskAnswer.clear()
    }
    
    private func setupViews() {
        clearScoreButton.setTitle("Сбросить счет", for: .normal)
        clearScoreButton.addTarget(self, action: #selector(didTapClearScoreButton), for: .touchUpInside)
    }
    
}
