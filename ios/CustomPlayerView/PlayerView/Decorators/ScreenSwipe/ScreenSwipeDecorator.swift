import UIKit
enum PanDirection: Int {
  case up, down, left, right
  public var isVertical: Bool { return [.up, .down].contains(self) }
  public var isHorizontal: Bool { return !isVertical }
}
extension UIPanGestureRecognizer {
  var direction: PanDirection? {
    let velocity = self.velocity(in: view)
    let isVertical = abs(velocity.y) > abs(velocity.x)
    switch (isVertical, velocity.x, velocity.y) {
    case (true, _, let y) where y < 0: return .up
    case (true, _, let y) where y > 0: return .down
    case (false, let x, _) where x > 0: return .right
    case (false, let x, _) where x < 0: return .left
    default: return nil
    }
  }
}
class ScreenSwipeDecorator: ScreenSwipeDecoratorType {
  var playerView: PlayerView?
  lazy var controlsContainerView = playerView?.controlsContainerView
  required init(_ playerView: PlayerView) {
    self.playerView = playerView
  }
  func addSwipeGesture() {
    guard let controlsContainer = controlsContainerView else { return }
    let tap = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
    controlsContainer.addGestureRecognizer(tap)
  }
  @objc func handlePan(_ sender: UIPanGestureRecognizer? = nil) {
    switch sender?.direction {
    case .up:
      print("Swiped up")
    case .down:
      print("Swiped down")
    case .left:
      print("Swiped left")
    case .right:
      print("Swiped right")
    default:
      break
    }
  }
}
