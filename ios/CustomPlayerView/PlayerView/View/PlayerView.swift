import Foundation
import BrightcovePlayerSDK
import AVKit
import GoogleCast
import BrightcoveGoogleCast;
@objc public protocol RCTPlayerProtocol: AnyObject {
  func nextVideoPlayer(_ dictionary: [String: String])
  func videoSize(_ width: CGFloat, height: CGFloat)
}
struct TimerControlConstants {
  static let hideControlsInterval: Double = 5
}
@objcMembers public class PlayerView: BCOVPUIPlayerView {
  private var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController!
  let castContext = GCKCastContext.sharedInstance()
  var mediaView: UIView!
  // MARK: - Abstract interfaces
  lazy var airplayDecorator: AirPlayableDecoratorType = {
    let decorator = AirplayDecorator(self)
    return decorator
  }()
  lazy var pictureInPictureDecorator: PictureInPictureDecoratorType = {
    let decorator = PictureInPictureDecorator(self)
    return decorator
  }()
  lazy var closedCaptionsDecorator: ClosedCaptionDecoratorType = {
    let decorator = ClosedCaptionsDecorator(self)
    return decorator
  }()
  lazy var mpCommandCenterDecorator: MPCommandCenterDecoratorType = {
    let decorator = MPRemoteCommandCenterDecorator(self)
    return decorator
  }()
  lazy var googleCastDecorator: GoogleCastDecoratorType = {
    let decorator = BCGoogleCastDecorator(self)
    return decorator
  }()
  lazy var overlayDecorator: ViewDecoratorType = {
    let decorator = OverlayDecorator(self)
    return decorator
  }()
  lazy var screenTapDecorator: ScreenTapDecoratorType = {
    let decorator = ScreenTapDecorator(self)
    return decorator
  }()
  lazy var screenSwipeDecorator: ScreenSwipeDecoratorType = {
    let decorator = SwipeDecorator(self)
    return decorator
  }()
  var customControlsView: CustomControlViewType?
  // MARK: - PlayerView properties
  var pictureInPicureEnabled: Bool = false {
    didSet {
      self.customControlsView?.pictureInPictureEnabled = pictureInPicureEnabled
    }
  }
  @objc weak var presentingViewController: UIViewController!
  var closedCaptionEnabled: Bool = false {
    didSet {
      customControlsView?.closedCaptionEnabled = closedCaptionEnabled
        customControlLayout.closedCaptions?.isHidden = !closedCaptionEnabled
    }
  }
    var audioEnabled: Bool = false {
      didSet {
        customControlsView?.audioEnabled = audioEnabled
          customControlLayout.audioCaptions?.isHidden = !audioEnabled
      }
    }
    
  var defaultFullScreen: Bool = false
  @objc public var screenMode: NSString? {
    didSet {
      switch screenMode {
      case "BCOVPUIScreenModeNormal":
        self.overlayDecorator.screenMode = .normal
      case "BCOVPUIScreenModeFull":
        self.overlayDecorator.screenMode = .full
      default:
        break
      }
      restablishTapTimer()
    }
  }
  @objc weak var player: RCTPlayerProtocol!
  @objc public var seekDuration: Double = SeekDuration.timeInterval {
    didSet {
      SeekDuration.timeInterval = seekDuration/1000
    }
  }
  @objc public var fontFamily: String = Font.fontType {
    didSet {
      Font.currentFont = FontFamily(rawValue: fontFamily) ?? .invalidFont
    }
  }
  @objc public var playlistAutoPlay: Bool = false {
    didSet {
      playlistRepo.playlistAutoPlay = playlistAutoPlay
    }
  }
  @objc public var showVideoEndOverlay: Bool = false {
    didSet {
      self.overlayDecorator.showOverlay = showVideoEndOverlay
    }
  }
  @objc public var progressTintColor: String = "#ff0000" {
    didSet {
    }
  }
  @objc public var accountId: String? {
    didSet {
      AccountConfig.accountId = accountId ?? StringConstants.kEmptyString
      self.executeRepository()
      setCastDecoratorProps()
    }
  }
  @objc public var policyKey: String? {
    didSet {
      AccountConfig.policyKey = policyKey ?? StringConstants.kEmptyString
      self.executeRepository()
      setCastDecoratorProps()
    }
  }
  @objc public var playlistReferenceId: String? {
    didSet {
      self.executeRepository()
    }
  }
  @objc public var playlistId: String? {
    didSet {
      self.executeRepository()
    }
  }
  @objc public var referenceId: String? {
    didSet {
      overlayDecorator.showOverlay = false
      self.addVideoSizeObserver()
      playlistRepo.referenceId = referenceId
      /*self.updateMPCommandCenter()*/
    }
  }
  @objc public var sliderDidChangeValue: NSNumber? {
    didSet {
      restablishTapTimer()
    }
  }
  @objc public var slider: UISlider? {
    didSet {
      self.sliderChanged()
      restablishTapTimer()
    }
  }
  @objc public var videoId: String? {
    didSet {
      overlayDecorator.showOverlay = false
      self.addVideoSizeObserver()
      playlistRepo.videoId = videoId
    }
  }
  var playlistRepo = PlayerRepository()
  @objc public var session: BCOVPlaybackSession? = nil {
    didSet {
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.checkIfPictureInPictureEnabled()
      }
        if let video = session?.video {
            print(video.properties)
            if let videoDuration = video.properties["duration"] as? Int, videoDuration <= 0 {
                if (!customControlLayout.currentLayoutLive) {
                    self.controlsView.layout = customControlLayout.setLayout(isLive: true).0
                }
            } else {
                if (customControlLayout.currentLayoutLive) {
                    self.controlsView.layout = customControlLayout.setLayout(isLive: false).0
                }
            }
        }
        
        customControlsView?.session = session
        customControlLayout.session = session
        overlayDecorator.session = session
        mpCommandCenterDecorator.session = session
    }
  }
  
  @objc public var lifecycleEvent: BCOVPlaybackSessionLifecycleEvent? {
    didSet {
      self.processLifeCycleEvents()
    }
  }
  let customControlLayout = CustomControlLayout()
  var handleForwardTap: (() -> Void)?
  @objc public weak var currentPlayer: AVPlayer? {
    didSet {
      customControlsView?.currentPlayer = currentPlayer
      customControlLayout.currentPlayer = currentPlayer
    }
  }
  // MARK: - init methods
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  public override func layoutSubviews() {
    super.layoutSubviews()
    //self.addControlsView()
  }
  @objc public init(presentingView: UIViewController,
                    playbackController: BCOVPlaybackController,
                    player: RCTPlayerProtocol) {
    let options = BCOVPUIPlayerViewOptions()
    // Need to revisit the impact/use of setting presentingViewController
    //options.presentingViewController = presentingView
    options.hideControlsInterval = TimerControlConstants.hideControlsInterval
    options.hideControlsAnimationDuration = 0.2
    options.showPictureInPictureButton = true // Must be true
    self.player = player
    self.presentingViewController = presentingView
    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
      options.presentingViewController = rootVC //RBR -103
    }
    self.playlistAutoPlay = false
    super.init(playbackController: playbackController, options: options, controlsView: BCOVPUIBasicControlView.withVODLayout())
    configurePlayerView()
    NotificationCenter.default.addObserver(self, selector: #selector(self.castStateDidChange),
                                           name: NSNotification.Name.gckCastStateDidChange,
                                           object: GCKCastContext.sharedInstance())
    configureCastDecorator()
    addMediaView()
    updateControlBarsVisibility(shouldAppear: false)
    let castContext = GCKCastContext.sharedInstance()
    miniMediaControlsViewController = castContext.createMiniMediaControlsViewController()
    miniMediaControlsViewController.delegate = self
    installViewController(miniMediaControlsViewController, inContainerView: mediaView!)
  }
  // MARK: - Configuring UI
  fileprivate func configurePlayerView() {
    // self.controlsView.pictureInPictureButton.isHidden = true
    configureCustomControls()
    setupControlsLayout()

    configureRedux()
    addOrientationObserver()
    screenTapDecorator.addTapGesture()
    addSwipeGesture()
    self.playbackController.add(self)
  }
  private func setupControlsLayout() {
    customControlLayout.playerView = self
    self.controlsView.layout = customControlLayout.setLayout(isLive: false).0
    controlsView.setFontSizeForLabels(16)
    self.customControlLayout.playbackController = self.playbackController
      guard let controls = customControlsView else { return }

      if let overlay = controls as? CustomOverlayControl, let audio = customControlLayout.audioCaptions, let captios = customControlLayout.closedCaptions{
          captios.addTarget(controls, action: #selector(CustomOverlayControl.handleClosedCaptionTapped), for: .touchUpInside)
          audio.addTarget(controls, action: #selector(CustomOverlayControl.handleAudioTapped), for: .touchUpInside)
//          overlay.closedCaptions = captios
//          overlay.audio = audio
          
      }
  }
  private func configureCustomControls() {
    addControlsView()
  }
  private func addControlsView() {
    customControlsView = CustomOverlayControl(self)
      
    guard let controls = customControlsView else { return }
    /*Not to delete. Commenting for RB alone*/
    /*controlsView.backgroundColor = UIColor.black
    if let visualEffectView = controlsView.backgroundView.subviews.first as? UIVisualEffectView {
      visualEffectView.isHidden = true
    }*/
    controlsView.currentTimeLabel.font = .systemFont(ofSize: ControlConstants.durationFontSize)
    controlsView.durationLabel.font = .systemFont(ofSize: ControlConstants.durationFontSize)
    controls.playbackController = self.playbackController
    controls.controlsViewHeight = RBPlayerControl.Metrics.smallWidth
    controlsFadingView.insertSubview(controls, belowSubview: controlsView)
    
    controls.centerInParentView(view: controlsFadingView)
    addClosedCaptionsObserver()
    addAudioObserver()
    addPictureInPictureObserver()
    addPlayPauseObserver()
    addForwardSeekObserver()
    addBackwardSeekObserver()
    addAirplayObserver()
    addClosedObserver()
    addMuteObserver()
    addInfoObserver()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      self.setDefaultOrientation()
    }
      
   
  }
  // MARK: - Orientations
  fileprivate func addOrientationObserver() {
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    // Commenting for Redbull. May be needed for other customers
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.orientationChanged(notification:)),
      name: UIDevice.orientationDidChangeNotification,
      object: nil)
  }
  func setDefaultOrientation() {
    if defaultFullScreen {
      self.customControlLayout.forceDefaultFullScreen()
    }
  }
  @objc func orientationChanged(notification: Notification) {
    if UIDevice.current.orientation.isLandscape {
      customControlLayout.setupLandscapeUI()
    } else if UIDevice.current.orientation.isPortrait {
      customControlLayout.setupPortraitUI()
    }
  }
  // MARK: - Player controls
  func displayNextVideo() {
    if let video = playlistRepo.getNextVideo() {
      setNextPlaylistVideo(video)
    } else {
      connectToRemote()
    }
  }
  func setNextPlaylistVideo(_ nextVideo: BCOVVideo) {
    overlayDecorator.nextPlaylistVideo = nextVideo
    overlayDecorator.showOverlay = true
  }
  func connectToRemote() {
    overlayDecorator.connectToRemote()
  }
  func playNextVideo() {
    if let video = playlistRepo.getNextVideo() {
      self.referenceId = video.properties[kBCOVVideoPropertyKeyReferenceId] as? String
      playlistRepo.referenceId = referenceId
      self.playbackController.setVideos([video] as NSFastEnumeration)
      let referenceId = video.properties[kBCOVVideoPropertyKeyReferenceId] as? String ?? StringConstants.kEmptyString
      let videoId = video.properties[kBCOVVideoPropertyKeyId] as? String ?? StringConstants.kEmptyString
      let dictVideoDetails = [NextVideoBridgeKeys.kReferenceId: referenceId,
                              NextVideoBridgeKeys.kVideoId: videoId]
      self.player.nextVideoPlayer(dictVideoDetails)
    }
  }
  func playPrevVideo() {
    if let video = playlistRepo.getPrevVideo() {
      self.referenceId = video.properties[kBCOVVideoPropertyKeyReferenceId] as? String
      playlistRepo.referenceId = referenceId
      self.playbackController.setVideos([video] as NSFastEnumeration)
      let referenceId = video.properties[kBCOVVideoPropertyKeyReferenceId] as? String ?? StringConstants.kEmptyString
      let videoId = video.properties[kBCOVVideoPropertyKeyId] as? String ?? StringConstants.kEmptyString
      let dictVideoDetails = [NextVideoBridgeKeys.kReferenceId: referenceId,
                              NextVideoBridgeKeys.kVideoId: videoId]
      self.player.nextVideoPlayer(dictVideoDetails)
    }
  }
  // MARK: - Execute data repository
  func executeRepository() {
    guard let accountId = self.accountId,
          let policyKey = self.policyKey
    else { return }
    playlistRepo = PlayerRepository(accountId, policyKey: policyKey)
    addPlaylistRepoObserver()
    if let playlistReferenceId = self.playlistReferenceId {
      playlistRepo.playlistReferenceId = playlistReferenceId
      playlistRepo.getPlaylistFromRefId()
    } else if let playlistId = self.playlistId {
      playlistRepo.playlistId = playlistId
      playlistRepo.getPlaylistFromPlaylistId()
    }
  }
  private func addPlaylistRepoObserver() {
    playlistRepo.playlistReady = { [weak self] in
      guard let self = self else { return }
      if self.playlistAutoPlay, let video = self.playlistRepo.playlistVideos?.first {
        self.playbackController.setVideos([video] as NSFastEnumeration)
        let referenceId = video.properties[kBCOVPlaylistPropertiesKeyReferenceId] as? String ?? StringConstants.kEmptyString
        let videoId = video.properties[kBCOVPlaylistPropertiesKeyId] as? String ?? StringConstants.kEmptyString
        let dictVideoDetails = [NextVideoBridgeKeys.kReferenceId: referenceId,
                                NextVideoBridgeKeys.kVideoId: videoId]
        self.referenceId = referenceId
        self.videoId = videoId
        self.player.nextVideoPlayer(dictVideoDetails)
      }
    }
  }
  func configureRedux() {
    OverlayReducer.shared.store?.subscribe(self)
  }
  func addVideoSizeObserver() {
    //Crash fix when Screen Rotates
    (overlayDecorator as? OverlayDecorator)?.videoSizeCallback = { [weak self] (width, height) in
      guard let self = self ,let player = self.player else { return }
      player.videoSize(width, height: height)
    }
  }
  @objc public func checkVideoSize() {
    (overlayDecorator as? OverlayDecorator)?.invokeVideoSizeCallback()
  }
  @objc public func screenModeChanged() {
    (overlayDecorator as? OverlayDecorator)?.resetConstraintsOnScreenModeChange()
  }
  @objc private func castStateDidChange(_ notification: Notification) {
      let state = GCKCastContext.sharedInstance().castState
      
      switch state {
      case .noDevicesAvailable:
          print("No cast devices available")
      case .connected:
          print("Cast device connected")
      case .connecting:
          print("Cast device connecting")
      case .notConnected:
          print("Cast device not connected")
      }
  }
  @objc public func clearSubscriber() {
    OverlayReducer.shared.store?.removeSubscriber(self)
    NotificationCenter.default.removeObserver(self)
    UIDevice.current.endGeneratingDeviceOrientationNotifications()
  }
  deinit {
    OverlayReducer.shared.store?.removeSubscriber(self)
    NotificationCenter.default.removeObserver(self)
    UIDevice.current.endGeneratingDeviceOrientationNotifications()
  }
  func updateControlBarsVisibility(shouldAppear: Bool = false) {
      if shouldAppear {
          mediaView!.isHidden = false
      } else {
            mediaView!.isHidden = true
      }
      UIView.animate(withDuration: 1, animations: { () -> Void in
          self.layoutIfNeeded()
      })
      setNeedsLayout()
  }
  func setCastDecoratorProps() {
    self.googleCastDecorator.accountId = self.accountId
    self.googleCastDecorator.policyKey = self.policyKey
  }
}
