//import Foundation
//import BrightcovePlayerSDK
//import GoogleCast
//import BrightcoveGoogleCast
//class BCGoogleCastDecorator: NSObject, PlayerDecoratorProtocol, GoogleCastable {
//  var accountId: String? {
//    didSet {
//      configureCast()
//    }
//  }
//  var policyKey: String? {
//    didSet {
//      configureCast()
//    }
//  }
//  weak var playerView: PlayerView?
//  let googleCastManager = GoogleCastManager.shared
//  var bcGoogleCastManager: BCOVGoogleCastManager!
//  required init(_ playerView: PlayerView) {
//    super.init()
//    self.playerView = playerView
//  }
//  func configureCastDecorator() {
//    let criteria = GCKDiscoveryCriteria(applicationID: kBCOVCAFReceiverApplicationID)
//    let options = GCKCastOptions(discoveryCriteria: criteria)
//    GCKCastContext.setSharedInstanceWith(options)
//    GCKLogger.sharedInstance().delegate = self.playerView
//    GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
//    if #available(iOS 15, *) { // Cast SDK Nav bar issue fix for iOS 15
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//    }
//  }
//  func configureCast() {
//    guard let accountId = self.accountId,
//    let policyKey =  self.policyKey else {
//      return
//    }
//    BCGoogleCastManager.shared.accountId = accountId
//    BCGoogleCastManager.shared.policyKey = policyKey
//    bcGoogleCastManager = BCGoogleCastManager.shared.googleCastManager
//    playerView?.playbackController.add(bcGoogleCastManager)
//    bcGoogleCastManager.delegate = self
//  }
//}
//extension BCGoogleCastDecorator: BCOVGoogleCastManagerDelegate {
//  var playbackController: BCOVPlaybackController? {
//    return self.playerView?.playbackController
//  }
//  
//  func switched(toLocalPlayback lastKnownStreamPosition: TimeInterval, withError error: Error?) {
//      if lastKnownStreamPosition > 0 {
//          playbackController?.play()
//      }
//    playerView?.isHidden = false
//
//      if let _error = error {
//          print("Switched to local playback with error: \(_error.localizedDescription)")
//      }
//    playerView?.updateControlBarsVisibility(shouldAppear: false)
//  }
//
//  func switchedToRemotePlayback() {
//    //GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()
//    playerView?.updateControlBarsVisibility(shouldAppear: true)
//    print("Suitable source for video not found!sdasd")
//  }
//
//  func currentCastedVideoDidComplete() {
//    self.playerView?.displayNextVideo()
//    print("Video completed")
//  }
//
//  func castedVideoFailedToPlay() {
//      print("Failed to play casted video")
//  }
//
//  func suitableSourceNotFound() {
//      print("Suitable source for video not found!")
//  }
//}
