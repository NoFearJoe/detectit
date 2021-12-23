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
    unowned let root: UIViewController
    
    func show(task: Task, bundle: TasksBundle.Info?, isTaskCompleted: Bool) {
        guard FullVersionManager.hasBought || task.taskDifficulty.rawValue < 3 else {
            let screen = FullVersionPurchaseScreen()
            screen.presentationController?.delegate = root as? UIAdaptivePresentationControllerDelegate
            
            return root.present(screen, animated: true, completion: nil)
        }
        
        let _screen: Screen? = {
            switch task.kind {
            case .cipher:
                guard let task = task as? DecoderTask else { return nil }
                return DecoderTaskScreen(
                    task: task,
                    bundle: bundle,
                    isTaskCompleted: isTaskCompleted
                )
            case .profile:
                guard let task = task as? ProfileTask else { return nil }
                return ProfileTaskScreen(
                    task: task,
                    bundle: bundle,
                    isTaskCompleted: isTaskCompleted
                )
            case .blitz:
                guard let task = task as? BlitzTask else { return nil }
                return BlitzTaskScreen(
                    task: task,
                    bundle: bundle,
                    isTaskCompleted: isTaskCompleted
                )
            case .quest:
                guard let task = task as? QuestTask else { return nil }
                return QuestTaskScreen(
                    task: task,
                    bundle: bundle,
                    isTaskCompleted: isTaskCompleted
                )
            }
        }()
        
        guard let screen = _screen else { return }
        
        screen.modalPresentationStyle = .fullScreen
        screen.modalTransitionStyle = .crossDissolve
        
        root.present(screen, animated: true, completion: nil)
    }
}
