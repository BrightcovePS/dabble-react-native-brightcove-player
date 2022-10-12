import Foundation
import BrightcovePlayerSDK
typealias ClosedCaptionDecoratorType = PlayerDecoratorProtocol & ClosedCaptionable & SessionReferenceable
/*LSP - Abstract interface shared by decorator and Playerview (core object)*/
protocol ClosedCaptionable: AnyObject {
  func addClosedCaptionsObserver()
  func presentClosedCaptions()
}
