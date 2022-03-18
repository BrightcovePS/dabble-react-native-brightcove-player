import Foundation
import BrightcovePlayerSDK
import GoogleCast
class GoogleCastDecorator: PlayerDecoratorProtocol, GoogleCastable {
  weak var playerView: PlayerView?
  let googleCastManager = GoogleCastManager.shared
  required init(_ playerView: PlayerView) {
    self.playerView = playerView
    configureCastDecorator()
  }
  func configureCastDecorator() {
    playerView?.playbackController.add(googleCastManager)
    googleCastManager.delegate = self
  }
}
