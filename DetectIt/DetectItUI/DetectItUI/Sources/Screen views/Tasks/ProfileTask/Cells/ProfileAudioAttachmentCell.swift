//
//  ProfileAudioAttachmentCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 15.08.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ProfileAudioAttachmentCell: AutosizingCollectionViewCell {
    
    public static let identifier = String(describing: ProfileAudioAttachmentCell.self)
    
    // MARK: - Subviews
    
    private let titleLabel = UILabel()
    
    private let audioPlayerController = AudioPlayerController()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public struct Model {
        public let title: String
        public let audio: Data
        
        public init(title: String, audio: Data) {
            self.title = title
            self.audio = audio
        }
    }
    
    public func configure(model: Model) {
        titleLabel.text = model.title
        audioPlayerController.configure(audio: model.audio)
    }
    
    // MARK: - Setup
    
    func setupViews() {
        contentView.addSubview(titleLabel)
        
        titleLabel.font = .heading3
        titleLabel.textColor = .lightGray
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        contentView.addSubview(audioPlayerController.view)
        
        audioPlayerController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            audioPlayerController.view.heightAnchor.constraint(equalToConstant: 64),
            audioPlayerController.view.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            audioPlayerController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            audioPlayerController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            audioPlayerController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
}
