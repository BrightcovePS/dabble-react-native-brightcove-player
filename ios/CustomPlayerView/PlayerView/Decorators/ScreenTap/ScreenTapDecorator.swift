import Foundation
class ScreenTapDecorator: PlayerDecoratorProtocol {
  weak var playerView: PlayerView?
  private var controlTimer: Timer?
  lazy var controlsContainerView = playerView?.controlsContainerView
  required init(_ playerView: PlayerView) {
    self.playerView = playerView
  }
  func addTapGesture() {
    guard let controlsContainer = controlsContainerView else { return }
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    controlsContainer.addGestureRecognizer(tap)
  }
  @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
    self.handleTap()
  }
  private func handleTap() {
      UIView.animate(withDuration: 0.1, animations: {
        self.showCustomControls()
      }) { [weak self](finished: Bool) in
        if finished {
          self?.reestablishTimer()
        }
      }
  }
  func reestablishTimer() {
    cancelTimer()
    controlTimer = Timer.scheduledTimer(timeInterval: TimerControlConstants.hideControlsInterval, target: self, selector: #selector(fadeControlsOut), userInfo: nil, repeats: false)
  }
  func cancelTimer() {
    if controlTimer?.isValid == true {
      controlTimer?.invalidate()
    }
  }
  @objc private func fadeControlsOut() {
    UIView.animate(withDuration: 0.2) {
      self.playerView?.controlsFadingViewVisible = false
    }
  }
  private func showCustomControls() {
    playerView?.controlsFadingViewVisible = !(playerView?.controlsFadingViewVisible ?? false)
    if (self.playerView?.controlsFadingViewVisible ?? false) {
      self.reestablishTimer()
    } else {
      cancelTimer()
    }
  }
  deinit {
    cancelTimer()
  }
}
