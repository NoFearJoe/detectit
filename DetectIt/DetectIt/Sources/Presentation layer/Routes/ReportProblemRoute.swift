//
//  ReportProblemRoute.swift
//  DetectIt
//
//  Created by Илья Харабет on 16.02.2022.
//  Copyright © 2022 Mesterra. All rights reserved.
//

import UIKit
import MessageUI

struct ReportProblemRoute {
    
    let root: UIViewController
    private static let delegate = Delegate()
    
    func show() {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let viewController = MFMailComposeViewController()
        viewController.setPreferredSendingEmailAddress("mesterra.co@gmail.com")
        viewController.setToRecipients(["mesterra.co@gmail.com"])
        viewController.setSubject("report_problem_subject".localized)
        viewController.mailComposeDelegate = Self.delegate
        
        root.present(viewController, animated: true, completion: nil)
    }
    
    private final class Delegate: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
}
