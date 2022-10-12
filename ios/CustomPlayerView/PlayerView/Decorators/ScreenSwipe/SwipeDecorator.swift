import UIKit
class SwipeDecorator: ScreenSwipeDecoratorType {
  var playerView: PlayerView?
  lazy var controlsContainerView = playerView?.controlsContainerView
  required init(_ playerView: PlayerView) {
    self.playerView = playerView
  }
  func addSwipeGesture() {
    guard let controlsContainer = controlsContainerView else { return }
    let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left, .up, .down]
    for direction in directions {
      let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(_:)))
      gesture.direction = direction
      controlsContainer.addGestureRecognizer(gesture)
    }
  }
  @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
    switch sender.direction {
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
