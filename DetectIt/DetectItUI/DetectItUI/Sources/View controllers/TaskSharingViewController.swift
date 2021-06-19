//
//  TaskSharingViewController.swift
//  DetectItUI
//
//  Created by Илья Харабет on 18.06.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

public final class TaskSharingViewController: UIViewController {
    
    private let sharingView = TaskSharingView()
    
    private let task: Task
    
    public init(task: Task) {
        self.task = task
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func loadView() {
        view = sharingView
        
        sharingView.onShare = { [unowned self] in
            self.share()
        }
    }
    
    private func share() {
        let controller = UIActivityViewController(
            activityItems: [makeSharingContent()],
            applicationActivities: nil
        )
        
        controller.overrideUserInterfaceStyle = .dark
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            controller.popoverPresentationController?.permittedArrowDirections = .down
            controller.popoverPresentationController?.sourceView = sharingView
        }
        
        present(controller, animated: true, completion: nil)
    }
    
    private func makeSharingContent() -> String {
        let taskLink = AppRateManager.appStoreLink.absoluteString
        
        switch task.kind {
        case .cipher:
            return String(format: "task_sharing_text_for_cipher".localized, task.title, taskLink)
        case .profile:
            return String(format: "task_sharing_text_for_profile".localized, task.title, taskLink)
        case .quest:
            return String(format: "task_sharing_text_for_quest".localized, task.title, taskLink)
        }
    }
    
}
