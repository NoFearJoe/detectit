//
//  AlertPresenter.swift
//  DetectItUI
//
//  Created by Илья Харабет on 06/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public enum AlertAction {
    case ok(String)
    case cancel
}

public protocol AlertPresenter: class {
    func showAlert(title: String?, message: String?, actions: [AlertAction], completion: ((AlertAction) -> Void)?)
    func hideAlert(animated: Bool)
}

public extension AlertPresenter where Self: UIViewController {
    
    func showAlert(title: String?, message: String?, actions: [AlertAction], completion: ((AlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { action in
            switch action {
            case let .ok(title):
                alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                    completion?(action)
                })
            case .cancel:
                // TODO
                alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in
                    completion?(action)
                })
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideAlert(animated: Bool) {
        guard let alert = self.presentedViewController as? UIAlertController else { return }
        alert.dismiss(animated: animated, completion: nil)
    }
    
}
