//
//  VideoPlayerView.swift
//  Sauron
//
//  Created by Justin Cook on 12/22/22.
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
