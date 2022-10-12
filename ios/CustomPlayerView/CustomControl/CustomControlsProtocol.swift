import Foundation
import BrightcovePlayerSDK
protocol CustomControlsProtocol: AnyObject {
  var pictureInPictureEnabled: Bool { get set }
  var closedCaptionEnabled: Bool { get set }
  var isPaused: Bool { get set }
  var isMuted: Bool { get set }
}
protocol CustomControlsActionable: AnyObject {
  var closedCaptionsTapped: ((UIButton) -> Void)? { get set }
  var pictureInPictureTapped: ((UIButton) -> Void)? { get set }
  var playPauseAction: ((UIButton) -> Void)? { get set }
  var rewindAction: ((UIButton) -> Void)? { get set }
  var forwardAction: ((UIButton) -> Void)? { get set }
  var airplayTapped: ((UIButton) -> Void)? { get set }
  var closeTapped: ((UIButton) -> Void)? { get set }
  var muteTapped: ((UIButton) -> Void)? { get set }
  var infoTapped: ((UIButton) -> Void)? { get set }
}
protocol CustomControlsObserverable: AnyObject {
  func addPlayPauseObserver()
  func addForwardSeekObserver()
  func addBackwardSeekObserver()
  func addClosedObserver()
  func addMuteObserver()
  func addInfoObserver()
}
