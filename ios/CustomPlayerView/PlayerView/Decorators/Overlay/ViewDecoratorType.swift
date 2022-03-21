import UIKit
import BrightcovePlayerSDK
protocol ViewDecoratorType: AnyObject, ViewDecoratorViewModelProtocol, ViewDecoratorRemoteProtocol, AnyVideoProtocol {
  var parentView: BCOVPUIPlayerView? { get set }
  init(_ view: BCOVPUIPlayerView)
  var showOverlay: Bool { get set }
  var isPreviewWindowActive: Bool { get set }
  var screenMode: BCOVPUIScreenMode? { get set }
  func hideOverylay()
  func unHideOverylay()
  func performOverlayAuxillaryActions()
  func performHideOverlayAuxillaryActions()
}
protocol ViewDecoratorViewModelProtocol {
  /*To set the video objects from the client player view*/
  var viewModel: GridViewModel { get set }
}
protocol ViewDecoratorRemoteProtocol {
  func connectToRemote()
}
protocol AnyVideoProtocol {
  var nextAnyVideo: BCOVVideo? { get set }
  func fetchAnyBCVideo(for json: [Videos]?)
}
