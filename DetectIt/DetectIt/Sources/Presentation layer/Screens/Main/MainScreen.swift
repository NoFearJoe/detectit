//
//  MainScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 01/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class MainScreen: Screen {
    
    // MARK: - State
    
    private let taskBundles = TasksBundles.allCases
    
    // MARK: - Overrides
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    override func loadView() {
        view = MainScreenView(delegate: self)
    }
    
    override func prepare() {
        super.prepare()
        
        isStatusBarBlurred = true
    }
    
}

extension MainScreen: MainScreenViewDelegate {
    
    func numberOfTaskBundles() -> Int {
        taskBundles.count
    }
    
    func tasksBundle(at index: Int) -> TasksBundleCell.Model? {
        let bundle = taskBundles[index]
        
        return TasksBundleCell.Model(
            backgroundImage: bundle.image,
            title: bundle.title,
            description: bundle.description,
            playState: .playable // TODO
        )
    }
    
    func didSelectTasksBundle(at index: Int) {
        let bundle = taskBundles[index]
        
        let tasksBundleScreen = TasksBundleScreen(tasksBundle: bundle)
        tasksBundleScreen.modalTransitionStyle = .coverVertical
        tasksBundleScreen.modalPresentationStyle = .fullScreen
        
        present(tasksBundleScreen, animated: true, completion: nil)
    }
    
    func didTapBuyTasksBundleButton(at index: Int) {
        
    }
    
}
