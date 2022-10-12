import Foundation
typealias ScreenTapDecoratorType = PlayerDecoratorProtocol & ScreenTapable
protocol ScreenTapable {
  func addTapGesture()
  func reestablishTimer()
  func cancelTimer()
}
