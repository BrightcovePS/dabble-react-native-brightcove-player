import Foundation
typealias MPCommandCenterDecoratorType = PlayerDecoratorProtocol & MPCommandCenterPlayable & SessionReferenceable
/*LSP - Abstract interface shared by decorator and Playerview (core object)*/
protocol MPCommandCenterPlayable: AnyObject {
  func setupNowPlayingInfoCenter()
  func updateMPCommandCenter()
}
