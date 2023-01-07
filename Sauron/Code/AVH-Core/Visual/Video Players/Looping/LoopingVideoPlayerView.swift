//
//  LoopingVideoPlayerView.swift
//  Inspec
//
//  Created by Justin Cook on 11/21/22.
//

import SwiftUI
import AVKit

struct LoopingVideoPlayerView: View {
    @StateObject var playbackCoordinator: LoopingVideoPlayerPlaybackCoordinator
    var videoPlayer: LoopingVideoPlayerUIViewRepresentable {
        return LoopingVideoPlayerUIViewRepresentable(lvpPlaybackCoordinator: self.playbackCoordinator)
    }
    
    var body: some View {
        videoPlayer
    }
}

struct LoopingVideoPlayerView_Previews: PreviewProvider {
    static func getVideo() -> AVPlayerItem {
        let videoAssetItem = Videos.getVideo(named: .Homescreen_B_Roll)
        
        return videoAssetItem
    }
    
    static func getLoopingVideoPlayerUIView() -> LoopingVideoPlayerUIView {
        return .init(video: getVideo())
    }
    
    static var previews: some View {
        LoopingVideoPlayerView(playbackCoordinator: .init(playerView: getLoopingVideoPlayerUIView()))
    }
}
