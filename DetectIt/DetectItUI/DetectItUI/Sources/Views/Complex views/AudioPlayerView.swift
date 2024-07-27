//
//  AudioPlayerView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 09.08.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import SwiftUI

public struct AudioPlayerViewSUI: UIViewRepresentable {
    public var isPlaying: Bool = false
    public var progress: Float = 0
    public var onPlay: (() -> Void)?
    public var onPause: (() -> Void)?
    
    public func makeUIView(context: Context) -> AudioPlayerView {
        AudioPlayerView()
    }
    
    public func updateUIView(_ uiView: AudioPlayerView, context: Context) {
        uiView.isPlaying = isPlaying
        uiView.progress = progress
        uiView.onPlay = onPlay
        uiView.onPause = onPause
    }
}

public final class AudioPlayerView: UIView {
    
    public var isPlaying: Bool = false {
        didSet {
            playButton.isHidden = isPlaying
            pauseButton.isHidden = !isPlaying
        }
    }
    
    public var progress: Float = 0 {
        didSet {
            progressBar.progress = progress
        }
    }
    
    public var onPlay: (() -> Void)?
    public var onPause: (() -> Void)?
    
    private let playButton = SolidButton()
    private let pauseButton = SolidButton()
    private let progressBar = UIProgressView(progressViewStyle: .default)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupViews() {
        addSubview(playButton)
        addSubview(pauseButton)
        
        playButton.setImage(UIImage.asset(named: "play"), for: .normal)
        pauseButton.setImage(UIImage.asset(named: "pause"), for: .normal)
        
        playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(didTapPauseButton), for: .touchUpInside)
        
        [playButton, pauseButton].forEach {
            $0.fill = .color(.lightGray)
            $0.tintColor = .black
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 26
            $0.layer.cornerCurve = .continuous
            $0.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: leadingAnchor),
                $0.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                $0.centerYAnchor.constraint(equalTo: centerYAnchor),
                $0.heightAnchor.constraint(equalToConstant: 52),
                $0.widthAnchor.constraint(equalTo: $0.heightAnchor)
            ])
        }
        
        addSubview(progressBar)
        
        progressBar.trackTintColor = .lightGray
        progressBar.progressTintColor = .yellow
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 12),
            progressBar.centerYAnchor.constraint(equalTo: centerYAnchor),
            progressBar.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc private func didTapPlayButton() {
        onPlay?()
    }
    
    @objc private func didTapPauseButton() {
        onPause?()
    }
    
}
