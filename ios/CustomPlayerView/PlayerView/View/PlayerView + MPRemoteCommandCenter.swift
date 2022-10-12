import Foundation
extension PlayerView: MPCommandCenterPlayable {
  func setupNowPlayingInfoCenter() {
    mpCommandCenterDecorator.setupNowPlayingInfoCenter()
  }
  func updateMPCommandCenter() {
    mpCommandCenterDecorator.updateMPCommandCenter()
  }
}
