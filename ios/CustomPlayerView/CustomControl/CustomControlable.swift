import UIKit
import BrightcovePlayerSDK
protocol CustomControlable: UIView {
  var playbackController: BCOVPlaybackController?  { get set }
  var session: BCOVPlaybackSession? { get set }
  var currentPlayer: AVPlayer?  { get set }
  var controlsViewHeight: CGFloat { get set }
}
