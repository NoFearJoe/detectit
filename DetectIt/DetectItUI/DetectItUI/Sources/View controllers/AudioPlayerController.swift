//
//  AudioPlayerController.swift
//  DetectItUI
//
//  Created by Илья Харабет on 09.08.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import AVFoundation

public final class AudioPlayerController: UIViewController {
    
    private let audioPlayerView = AudioPlayerView()
        
    private var player: AVAudioPlayer?
    
    private var timer: Timer?
    
    public override func loadView() {
        view = audioPlayerView
        
        audioPlayerView.isPlaying = false
        audioPlayerView.onPlay = { [unowned self] in
            self.play()
        }
        audioPlayerView.onPause = { [unowned self] in
            self.pause()
        }
    }
    
    public func configure(audio: Data) {
        player = try? AVAudioPlayer(data: audio)
        player?.delegate = self
        player?.prepareToPlay()
    }
    
    private func play() {
        audioPlayerView.isPlaying = true
        
        player?.play()
        
        subscribeToProgressUpdate()
    }
    
    private func pause() {
        audioPlayerView.isPlaying = false
        
        player?.pause()
        
        unsubscribeFromProgressUpdate()
    }
    
    deinit {
        player?.stop()
        unsubscribeFromProgressUpdate()
    }
    
    private func subscribeToProgressUpdate() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            
            self.audioPlayerView.progress = Float(player.currentTime / player.duration)
        })
    }
    
    private func unsubscribeFromProgressUpdate() {
        timer?.invalidate()
        timer = nil
    }
    
}

extension AudioPlayerController: AVAudioPlayerDelegate {
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayerView.progress = Float(player.currentTime / player.duration)
        audioPlayerView.isPlaying = false
        
        unsubscribeFromProgressUpdate()
    }
    
}
