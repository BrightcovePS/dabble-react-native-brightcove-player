import Foundation
class AirplayDecorator: AirPlayableDecoratorType {
  weak var playerView: PlayerView?
  required init(_ playerView: PlayerView) {
    self.playerView = playerView
  }
  func addAirplayObserver() {
    self.playerView?.customControlsView?.airplayTapped = {
      [weak self] _ in
      guard let self = self else { return }
      self.startAirplay()
    }
  }
  func startAirplay() {
    self.playerView?.controlsView.externalRouteViewButton.sendActions(for: .touchUpInside)
  }
}
