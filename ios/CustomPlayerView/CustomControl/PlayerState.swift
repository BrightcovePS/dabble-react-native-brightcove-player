//
//  PlayerState.swift
//  react-native-brightcove-player
//
//  Created by jenix_gnanadhas on 07/11/23.
//

import Foundation
enum PlayerState {
  case finished
  case playing
  case paused
  case ready
  case terminate
  case end
  case buffer
  case unknown
}

enum PlaybackType {
  case episodic
  case nonEpisodic
  case unknown
}

