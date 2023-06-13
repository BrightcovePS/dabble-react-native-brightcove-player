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
    
    func addAudioObserver() {
      self.playerView?.customControlsView?.audioTapped = {
        [weak self] _ in
        guard let self = self else { return }
        self.presentAudio()
      }
    }
    
    func presentClosedCaptions() {
        let navController = UINavigationController(rootViewController: self.ccMenuController)
        if self.playerView?.session?.player.timeControlStatus == .playing {
            ccMenuController.shouldPlayOnClose = true
        }
        ccMenuController.title = "Subtitles & CC"
        ccMenuController.characteristic = .legible
        ccMenuController.currentSession = session
        self.playerView?.parentViewController?.present(navController, animated: true, completion: nil)
    }
    
    func presentAudio() {
        let navController = UINavigationController(rootViewController: self.ccMenuController)
        if self.playerView?.session?.player.timeControlStatus == .playing {
            ccMenuController.shouldPlayOnClose = true
        }
        ccMenuController.title = "Audio"
        ccMenuController.characteristic = .audible
        ccMenuController.currentSession = session
        self.playerView?.parentViewController?.present(navController, animated: true, completion: nil)
    }
}
