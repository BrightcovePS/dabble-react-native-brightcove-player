import Foundation
typealias ScreenSwipeDecoratorType = PlayerDecoratorProtocol & ScreenSwipeable
protocol ScreenSwipeable {
  func addSwipeGesture()
}
