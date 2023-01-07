//
//  GenericVideoPlaybackCoordinator.swift
//  Inspec
//
//  Created by Justin Cook on 11/22/22.
//

import AVKit

protocol GenericVideoPlaybackCoordinator: ObservableObject {
    // MARK: - Managed View
    var playerView: LoopingVideoPlayerUIView { get set }
    
    // MARK: - State Management
    var isPlaying: Bool { get }
    var isMuted: Bool { get }
    
    // MARK: - Shared session functions
    func allowSharedAudioStream()
    func disableSharedAudioStream()
    
    // MARK: - Controls
    func start()
    func pause()
    
    // MARK: - Audio
    func muteAudio()
    func unmuteAudio()
}

extension GenericVideoPlaybackCoordinator {
    /// Gives audio coming from other applications the ability to be played and mixed with the current shared audio output stream
    func allowSharedAudioStream() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Gives priority to this app's audio output stream, no other app's audio can be mixed with the current audio
    func disableSharedAudioStream() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient)
        } catch {
            print(error.localizedDescription)
        }
    }
}
