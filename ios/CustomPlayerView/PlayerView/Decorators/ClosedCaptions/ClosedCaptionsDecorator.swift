import Foundation
import BrightcovePlayerSDK
class ClosedCaptionsDecorator: PlayerDecoratorProtocol, ClosedCaptionable, SessionReferenceable {
  weak var playerView: PlayerView?
  var session: BCOVPlaybackSession? {
    didSet {
      ccMenuController.currentSession = session
    }
  }
  lazy var ccMenuController: CustomClosedCaptionsMenuController = {
    let _ccMenuController = CustomClosedCaptionsMenuController(style: .grouped)
    _ccMenuController.controlsView = playerView
    return _ccMenuController
  }()
  required init(_ playerView: PlayerView) {
    self.playerView = playerView
  }
  func addClosedCaptionsObserver() {
    self.playerView?.customControlsView?.closedCaptionsTapped = {
      [weak self] _ in
      guard let self = self else { return }
      self.presentClosedCaptions()
    }
  }
  func presentClosedCaptions() {
    let navController = UINavigationController(rootViewController: self.ccMenuController)
    if self.playerView?.session?.player.timeControlStatus == .playing {
      ccMenuController.shouldPlayOnClose = true
    }
    self.playerView?.parentViewController?.present(navController, animated: true, completion: nil)
  }
}
