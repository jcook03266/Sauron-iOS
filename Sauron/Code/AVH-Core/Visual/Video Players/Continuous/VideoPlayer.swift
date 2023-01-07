//
//  VideoPlayerView.swift
//  Inspec
//
//  Created by Justin Cook on 11/21/22.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    var AVPlayer: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: AVPlayer)
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static func getAVPlayer() -> AVPlayer {
        let videoAssetItem = Videos.getVideo(named: .Homescreen_B_Roll)
        let player = AVPlayer(playerItem: videoAssetItem)
        
        return player
    }
    
    static var previews: some View {
        VideoPlayerView(AVPlayer: getAVPlayer())
    }
}
