import Foundation
import BrightcovePlayerSDK
protocol CustomControlsProtocol: AnyObject {
  var pictureInPictureEnabled: Bool { get set }
  var closedCaptionEnabled: Bool { get set }
  var isPaused: Bool { get set }
}
protocol CustomControlsActionable: AnyObject {
  var closedCaptionsTapped: ((UIButton) -> Void)? { get set }
  var pictureInPictureTapped: ((UIButton) -> Void)? { get set }
  var playPauseAction: ((UIButton) -> Void)? { get set }
}
protocol CustomControlsObserverable: AnyObject {
  func addPlayPauseObserver()
}
