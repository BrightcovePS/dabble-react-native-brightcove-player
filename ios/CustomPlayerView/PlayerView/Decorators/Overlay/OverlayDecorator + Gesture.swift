import UIKit
fileprivate struct SwipeConstants {
  static var animDuration = 0.2
  static var yMax: CGFloat = 270
  static var yMin: CGFloat = 110
  static var yMinThreshold: CGFloat = 140
  static var yMaxThreshold: CGFloat = 220
}
extension OverlayDecorator: UIGestureRecognizerDelegate {
  @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
    if gestureRecognizer.state == UIGestureRecognizer.State.ended {
      gestureEndAnimation(gestureRecognizer)
    }
    if gestureRecognizer.state == UIGestureRecognizer.State.began || gestureRecognizer.state == UIGestureRecognizer.State.changed {
      gestureChangedAnimation(gestureRecognizer)
    }
  }
  fileprivate func gestureEndAnimation(_ gestureRecognizer: UIPanGestureRecognizer) {
    print("gestureEndAnimation",SwipeConstants.yMaxThreshold)
    print("gestureEndAnimation",SwipeConstants.yMinThreshold)
    print("gestureEndAnimation",SwipeConstants.yMax)
    print("gestureEndAnimation",SwipeConstants.yMin)
    guard let gestureView = gestureRecognizer.view else { return }
    print("gestureEndAnimation -> Y", gestureView.center.y)
    let velocity = gestureRecognizer.velocity(in: self.gridContainer)
    if velocity.y > 0 { // Scrolling down
      if(gestureView.center.y <= SwipeConstants.yMinThreshold) {
        UIView.animate(withDuration: SwipeConstants.animDuration) {
          gestureView.center = CGPoint(x:gestureView.center.x, y:SwipeConstants.yMax)
        }
      }else {
        UIView.animate(withDuration: SwipeConstants.animDuration) {
          gestureView.center = CGPoint(x:gestureView.center.x, y: SwipeConstants.yMin)
        }
      }
    } else { // Scrolling up
      if(gestureView.center.y >= SwipeConstants.yMaxThreshold + 50) {
        UIView.animate(withDuration: SwipeConstants.animDuration) {
          gestureView.center = CGPoint(x:gestureView.center.x, y: SwipeConstants.yMin)
        }
      }else {
        UIView.animate(withDuration: SwipeConstants.animDuration) {
          gestureView.center = CGPoint(x:gestureView.center.x, y:SwipeConstants.yMax)
        }
      }
    }
    print(gestureView.center.y)
    gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.gridContainer)
  }
  fileprivate func gestureChangedAnimation(_ gestureRecognizer: UIPanGestureRecognizer) {
    guard let gestureView = gestureRecognizer.view else { return }
    print("Gestureview frame >>>>>>>>", gestureView, gestureView.frame.maxY)
    SwipeConstants.yMaxThreshold =  self.parentView!.overlayView.frame.height - 100
    SwipeConstants.yMinThreshold =  self.parentView!.overlayView.frame.height/2 + 30
    SwipeConstants.yMax =  self.parentView!.overlayView.frame.height/2
    SwipeConstants.yMin = self.parentView!.overlayView.frame.height
//    print(SwipeConstants.yMaxThreshold)
//    print(SwipeConstants.yMinThreshold)
//    print(SwipeConstants.yMax)
//    print(SwipeConstants.yMin)
    let translation = gestureRecognizer.translation(in: self.gridContainer)
    let velocity = gestureRecognizer.velocity(in: self.gridContainer)
    if velocity.y > 0 { // Scrolling down
      if(gestureView.center.y <= SwipeConstants.yMinThreshold) {
        gestureView.center = CGPoint(x: gestureView.center.x, y: gestureView.center.y + translation.y)
      }else {
        UIView.animate(withDuration: SwipeConstants.animDuration) {
          gestureView.center = CGPoint(x:gestureView.center.x, y: SwipeConstants.yMin)
        }
      }
    } else { // Scrolling up
      if(gestureView.center.y >= SwipeConstants.yMaxThreshold) {
        gestureView.center = CGPoint(x: gestureView.center.x, y: gestureView.center.y + translation.y)
      }else {
        UIView.animate(withDuration: SwipeConstants.animDuration) {
          gestureView.center = CGPoint(x:gestureView.center.x, y:SwipeConstants.yMax)
        }
      }
    }
    print(gestureView.center.y)
    gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.gridContainer)
  }
}
