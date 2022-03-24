import Foundation
import BrightcovePlayerSDK
import AVKit
struct TimerControlConstants {
  static let hideControlsInterval: Double = 3
}
@objcMembers public class PlayerView: BCOVPUIPlayerView {
  // MARK: - Abstract interfaces
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
    let decorator = GoogleCastDecorator(self)
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
    }
  }
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
    }
  }
  @objc weak var player: BrightcovePlayer!
  @objc public var seekDuration: Double = SeekDuration.timeInterval {
    didSet {
      SeekDuration.timeInterval = seekDuration
    }
  }
  @objc public var showVideoEndOverlay: Bool = false {
    didSet {
      self.overlayDecorator.showOverlay = showVideoEndOverlay
    }
  }
  @objc public var accountId: String? {
    didSet {
      AccountConfig.accountId = accountId ?? StringConstants.kEmptyString
      self.executeRepository()
    }
  }
  @objc public var policyKey: String? {
    didSet {
      AccountConfig.policyKey = policyKey ?? StringConstants.kEmptyString
      self.executeRepository()
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
      playlistRepo.referenceId = referenceId
      /*self.updateMPCommandCenter()*/
    }
  }
  @objc public var slider: UISlider? {
    didSet {
      self.sliderChanged()
    }
  }
  @objc public var videoId: String? {
    didSet {
      overlayDecorator.showOverlay = false
      playlistRepo.videoId = videoId
    }
  }
  var playlistRepo = PlayerRepository()
  @objc public var session: BCOVPlaybackSession? = nil {
    didSet {
      customControlsView?.session = session
      customControlLayout.session = session
      overlayDecorator.session = session
      mpCommandCenterDecorator.session = session
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.checkIfPictureInPictureEnabled()
      }
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
                    player: BrightcovePlayer) {
    let options = BCOVPUIPlayerViewOptions()
    // Need to revisit the impact/use of setting presentingViewController
    //options.presentingViewController = presentingView
    options.hideControlsInterval = TimerControlConstants.hideControlsInterval
    options.hideControlsAnimationDuration = 0.2
    //options.showPictureInPictureButton = true // Must be true
    self.player = player
    self.presentingViewController = presentingView
    super.init(playbackController: playbackController, options: options, controlsView: BCOVPUIBasicControlView.withVODLayout())
    configurePlayerView()
  }
  // MARK: - Configuring UI
  fileprivate func configurePlayerView() {
    setupControlsLayout()
    // self.controlsView.pictureInPictureButton.isHidden = true
    configureCustomControls()
    configureRedux()
    addOrientationObserver()
    screenTapDecorator.addTapGesture()
    self.playbackController.add(self)
  }
  private func setupControlsLayout() {
    customControlLayout.playerView = self
    self.controlsView.layout = customControlLayout.setLayout().0
    controlsView.setFontSizeForLabels(16)
    self.customControlLayout.playbackController = self.playbackController
  }
  private func configureCustomControls() {
    addControlsView()
  }
  private func addControlsView() {
    customControlsView = CustomOverlayControl()
    guard let controls = customControlsView else { return }
    /*Not to delete. Commenting for RB alone*/
    /*controlsView.backgroundColor = UIColor.black
    if let visualEffectView = controlsView.backgroundView.subviews.first as? UIVisualEffectView {
      visualEffectView.isHidden = true
    }*/
    controls.playbackController = self.playbackController
    controls.controlsViewHeight = 40
    controlsFadingView.insertSubview(controls, belowSubview: controlsView)
    controls.centerInParentView(view: controlsFadingView)
    addClosedCaptionsObserver()
    addPictureInPictureObserver()
    addPlayPauseObserver()
    addForwardSeekObserver()
    addBackwardSeekObserver()
  }
  // MARK: - Orientations
  fileprivate func addOrientationObserver() {
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    // Commenting for Redbull. May be needed for other customers
    /*NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.orientationChanged(notification:)),
      name: UIDevice.orientationDidChangeNotification,
      object: nil)*/
  }
  @objc func orientationChanged(notification: Notification) {
    if UIDevice.current.orientation.isLandscape {
      customControlLayout.forceFullScreen()
    } else if UIDevice.current.orientation.isPortrait {
      customControlLayout.forcePortrait()
    }
  }
  // MARK: - Player controls
  func displayNextVideo() {
    if let video = playlistRepo.getNextVideo() {
      setNextPlaylistVideo(video)
    } else {
      if CurrentPlayerItem.shared.allVideosInAccount.count > 0 {
        connectToRemote()
      }
      overlayDecorator.showOverlay = overlayDecorator.nextAnyVideo != nil ? true: false
      //overlayDecorator.connectToRemote() Commented for 10 sec buffer
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
      self.referenceId = video.properties[kBCOVPlaylistPropertiesKeyReferenceId] as? String
      playlistRepo.referenceId = referenceId
      self.playbackController.setVideos([video] as NSFastEnumeration)
      let referenceId = video.properties[kBCOVPlaylistPropertiesKeyReferenceId] as? String ?? StringConstants.kEmptyString
      let videoId = video.properties[kBCOVPlaylistPropertiesKeyId] as? String ?? StringConstants.kEmptyString
      let dictVideoDetails = [NextVideoBridgeKeys.kReferenceId: referenceId,
                              NextVideoBridgeKeys.kVideoId: videoId]
      self.player.nextVideoPlayer(dictVideoDetails)
    }
  }
  func playPrevVideo() {
    if let video = playlistRepo.getPrevVideo() {
      self.referenceId = video.properties[kBCOVPlaylistPropertiesKeyReferenceId] as? String
      playlistRepo.referenceId = referenceId
      self.playbackController.setVideos([video] as NSFastEnumeration)
      let referenceId = video.properties[kBCOVPlaylistPropertiesKeyReferenceId] as? String ?? StringConstants.kEmptyString
      let videoId = video.properties[kBCOVPlaylistPropertiesKeyId] as? String ?? StringConstants.kEmptyString
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
    if let playlistReferenceId = self.playlistReferenceId {
      playlistRepo.playlistReferenceId = playlistReferenceId
      playlistRepo.getPlaylistFromRefId()
    } else if let playlistId = self.playlistId {
      playlistRepo.playlistId = playlistId
      playlistRepo.getPlaylistFromPlaylistId()
    }
  }
  func configureRedux() {
    OverlayReducer.shared.store?.subscribe(self)
  }
  @objc public func screenModeChanged() {
    (overlayDecorator as? OverlayDecorator)?.resetConstraintsOnScreenModeChange()
  }
  deinit {
    OverlayReducer.shared.store?.removeSubscriber(self)
    NotificationCenter.default.removeObserver(self)
    UIDevice.current.endGeneratingDeviceOrientationNotifications()
  }
}
