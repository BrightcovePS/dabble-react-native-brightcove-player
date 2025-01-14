import Foundation
extension PlayerView: ScreenTapable {
  func addTapGesture() {
    screenTapDecorator.addTapGesture()
  }
  func reestablishTimer() {
    screenTapDecorator.reestablishTimer()
  }
  func cancelTimer() {
    screenTapDecorator.cancelTimer()
  }
}
