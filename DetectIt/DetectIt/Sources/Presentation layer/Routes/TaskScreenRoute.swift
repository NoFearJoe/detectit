//
//  TaskScreenRoute.swift
//  DetectIt
//
//  Created by Илья Харабет on 28/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

struct TaskScreenRoute {
    let root: UIViewController
    
    func show(task: Task, bundle: TasksBundle.Info?) {
        let _screen: Screen? = {
            switch task {
            case let task as DecoderTask:
                return DecoderTaskScreen(
                    task: task,
                    bundle: bundle
                )
            case let task as ProfileTask:
                return ProfileTaskScreen(
                    task: task,
                    bundle: bundle
                )
            case let task as QuestTask:
                return QuestTaskScreen(
                    task: task,
                    bundle: bundle
                )
            default:
                return nil
            }
        }()
        
        guard let screen = _screen else { return }
        
        screen.modalPresentationStyle = .fullScreen
        screen.modalTransitionStyle = .crossDissolve
        
        root.present(screen, animated: true, completion: nil)
    }
}
