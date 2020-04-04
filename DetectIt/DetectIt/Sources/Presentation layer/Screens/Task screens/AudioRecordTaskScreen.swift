//
//  AudioRecordTaskScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class AudioRecordTaskScreen: Screen {
    
    // MARK: - Init
    
    private let task: AudioRecordTask
    private let bundle: TasksBundle
    
    init(task: AudioRecordTask, bundle: TasksBundle) {
        self.task = task
        self.bundle = bundle
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
}
