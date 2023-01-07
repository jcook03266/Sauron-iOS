//
//  LoopingVideoPlayerUIView.swift
//  Inspec
//
//  Created by Justin Cook on 11/21/22.
//

import SwiftUI
import UIKit
import AVKit

/// Enhanced video player that loops indefinitely given a specified AVPlayerItem
struct LoopingVideoPlayerUIViewRepresentable: UIViewRepresentable {
    typealias UIViewType = LoopingVideoPlayerUIView
    
    @StateObject var lvpPlaybackCoordinator: LoopingVideoPlayerPlaybackCoordinator
    
    func makeUIView(context: Context) -> LoopingVideoPlayerUIView {
        return lvpPlaybackCoordinator.playerView
    }
    
    func updateUIView(_ uiView: LoopingVideoPlayerUIView,
                      context: Context)
    {}
}

/// Object that acts as the middle-man between the UView and its View counterpart
class LoopingVideoPlayerPlaybackCoordinator: GenericVideoPlaybackCoordinator {
    // MARK: - Published
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var isMuted: Bool = true // Preferred to be muted by default
    @Published var playerView: LoopingVideoPlayerUIView
    
    init(playerView: LoopingVideoPlayerUIView) {
        self.playerView = playerView
    }
    
    func start() {
        isPlaying = true
        playerView.beginPlayback()
    }
    
    func pause() {
        isPlaying =  false
        playerView.pausePlayback()
        
        allowSharedAudioStream()
    }
    
    func muteAudio() {
        isMuted = true
        playerView.muteAudio()
        
        allowSharedAudioStream()
    }
    
    func unmuteAudio() {
        isMuted = false
        playerView.unmuteAudio()
        
        disableSharedAudioStream()
    }
}

class LoopingVideoPlayerUIView: UIView {
    // MARK: - Playback objects
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?,
    player: AVQueuePlayer = AVQueuePlayer()
    
    // MARK: - Video Assets
    var video: AVPlayerItem
    
    init(video: AVPlayerItem) {
        self.video = video
        super.init(frame: .zero)
        
        performSetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    func performSetup() {
        // Configure player
        playerLayer.player = self.player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        // Init looper
        playerLooper = AVPlayerLooper(player: player,
                                      templateItem: video)
    }
    
    // MARK: - Playback controls
    func beginPlayback() {
        player.play()
    }
    
    func pausePlayback() {
        player.pause()
    }
    
    func muteAudio() {
        player.isMuted = true
    }
    
    func unmuteAudio() {
        player.isMuted = false
    }
    
    required init?(coder: NSCoder) {
        ErrorCodeDispatcher.SwiftErrors.triggerFatalError(for: .inheritedCoderNotImplemented)()
    }
}
