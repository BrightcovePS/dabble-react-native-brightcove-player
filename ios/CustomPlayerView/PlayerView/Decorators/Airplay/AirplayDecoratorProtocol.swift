import Foundation
typealias AirPlayableDecoratorType = PlayerDecoratorProtocol & AirPlayable
/*LSP - Abstract interface shared by decorator and Playerview (core object)*/
protocol AirPlayable: AnyObject {
  func addAirplayObserver()
}
