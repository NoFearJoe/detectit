//
//  DecoderTaskScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class DecoderTaskScreen: Screen {
    
    // MARK: - Subviews
    
    private let contentContainer = StackViewController()
    
    private let closeButton = SolidButton.closeButton()
    
    private let titleLabel = UILabel()
    private let prepositionLabel = UILabel()
    private let encodedPictureView = UIImageView()
    
    // MARK: - State
    
    private let task: DecoderTask
    private let bundle: TasksBundle
        
    // MARK: - Init
    
    init(task: DecoderTask, bundle: TasksBundle) {
        self.task = task
        self.bundle = bundle
        
        super.init(nibName: nil, bundle: nil)
        
        addChild(contentContainer)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Overrides
    
    override func loadView() {
        super.loadView()
        
        contentContainer.place(into: self)
        
        setupViews()
        setupContentView()
    }
    
    override func prepare() {
        super.prepare()
        
        displayContent(encodedPicture: UIImage.asset(named: "Test")!)
        
        // Show loader (skeleton)
        loadData { [weak self] image in
            guard let image = image else {
                // TODO: Show error placeholder
                return
            }
            
            self?.displayContent(encodedPicture: image)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapEncodedPicture() {
        // TODO: Show image viewer
    }
    
    // MARK: - Utils
    
    private func loadData(completion: @escaping (UIImage?) -> Void) {
        guard let imageURL = task.encodedPictureURL(bundleID: bundle.id) else {
            return completion(nil)
        }
        
        ImageLoader.share.load(
            .file(imageURL)
        ) { image in
            completion(image)
        }
    }
    
    private func displayContent(encodedPicture: UIImage) {
        titleLabel.text = task.title
        prepositionLabel.text = task.preposition
        encodedPictureView.image = encodedPicture
    }
    
    // MARK: - Setup
    
    private func setupContentView() {
        contentContainer.view.backgroundColor = .black
        
        contentContainer.stackView.layoutMargins = UIEdgeInsets(
            top: 0, left: 20, bottom: 0, right: 20
        )
        
        contentContainer.setTopSpacing(20)
        contentContainer.appendChild(titleLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(prepositionLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(encodedPictureView)
        contentContainer.setBottomSpacing(20)
    }
    
    private func setupViews() {
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        titleLabel.font = .bold(28)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        prepositionLabel.font = .regular(14)
        prepositionLabel.textColor = .white
        prepositionLabel.numberOfLines = 0
        
        encodedPictureView.layer.allowsEdgeAntialiasing = true
        encodedPictureView.transform = CGAffineTransform
            .randomLayout()
            .concatenating(CGAffineTransform(scaleX: 0.9, y: 0.9))
        
        encodedPictureView.configureShadow(radius: 20, opacity: 0.2, color: .white, offset: .zero)
        
        encodedPictureView.isUserInteractionEnabled = true
        encodedPictureView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapEncodedPicture))
        )
    }
    
}
