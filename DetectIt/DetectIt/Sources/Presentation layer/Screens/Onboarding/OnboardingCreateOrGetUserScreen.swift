//
//  OnboardingCreateOrGetUserScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 28/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore
import DetectItAPI

final class OnboardingCreateOrGetUserScreen: Screen {
    
    var onFinish: (() -> Void)?
    
    private let skeleton = ScreenLoadingView(isInitiallyHidden: true)
    
    private let api = DetectItAPI()
    
    private let alias: String
    
    init(alias: String) {
        self.alias = alias
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepare() {
        super.prepare()
        
        view.addSubview(skeleton)
        
        skeleton.pin(to: self.view)
        
        performUserCreation()
    }
    
    private func performUserCreation() {
        skeleton.setVisible(true, animated: false)
        screenPlaceholderView.setVisible(false, animated: true)
        
        api.request(.createUser(alias: alias)) { [weak self] result in
            switch result {
            case let .success(response):
                guard let user = try? JSONDecoder().decode(UserEntity.self, from: response.data) else {
                    self?.screenPlaceholderView.setVisible(true, animated: true)
                    self?.screenPlaceholderView.configure(
                        title: "unknown_error_title".localized,
                        message: "unknown_error_message".localized,
                        onRetry: { [unowned self] in self?.performUserCreation() }
                    )
                    
                    return
                }
                
                User.shared.id = user.id
                User.shared.alias = user.alias
                
                self?.onFinish?()
            case .failure:
                self?.screenPlaceholderView.setVisible(true, animated: true)
                self?.screenPlaceholderView.configure(
                    title: "network_error_title".localized, // TODO: Может показать другую надпись? Чтобы было понятнее
                    message: "netowrk_error_message".localized,
                    onRetry: { [unowned self] in self?.performUserCreation() }
                )
            }
        }
    }
    
}
