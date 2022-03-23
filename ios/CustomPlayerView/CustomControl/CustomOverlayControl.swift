import UIKit
import BrightcovePlayerSDK
import AVKit
import GoogleCast
struct SeekDuration {
  static var timeInterval: Double = 15
}
fileprivate struct ControlConstants {
  static let VisibleDuration: TimeInterval = 5.0
  static let AnimateInDuration: TimeInterval = 0.1
  static let AnimateOutDuraton: TimeInterval = 0.2
  static var seekDuration: Double {
    return SeekDuration.timeInterval
  }
}
class CustomOverlayControl: UIView, CustomControlViewType {
  var pictureInPictureEnabled: Bool = false {
    didSet {
        self.pictureInPicture.isEnabled = pictureInPictureEnabled
    }
  }
  var closedCaptionEnabled: Bool = false {
    didSet {
        self.closedCaptions.isEnabled = closedCaptionEnabled
    }
  }
  var isPaused: Bool = false {
    didSet {
      if isPaused {
        self.setPlayImage()
      } else {
        self.setPauseImage()
      }
    }
  }
  weak var playbackController: BCOVPlaybackController?
  weak var session: BCOVPlaybackSession? = nil
  weak var currentPlayer: AVPlayer?
  var playPauseAction: ((UIButton) -> Void)?
  var rewindAction: ((UIButton) -> Void)?
  var forwardAction: ((UIButton) -> Void)?
  var closedCaptionsTapped: ((UIButton) -> Void)?
  var pictureInPictureTapped: ((UIButton) -> Void)?
  var controlsViewHeight: CGFloat = 0 {
    didSet {
      self.addControls()
    }
  }
  private lazy var topControlsStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.distribution = .fill
   // stackView.spacing = RBPlayerControl.Metrics.smallSpacing
    return stackView
  }()
  var googleCastButton: GCKUICastButton = {
    let button = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
    button.tintColor = UIColor.gray
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  lazy var pictureInPicture: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: RBPlayerControl.Assets.pictureinpicture)?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.imageView?.tintColor = .white
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = RBPlayerControl.Metrics.buttonEdgeInset
    button.isEnabled = false
    return button
  }()
  lazy var airplayBtn: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
   // button.setImage(UIImage(named: RBPlayerControl.Assets.airplay)?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.imageView?.tintColor = .white
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = RBPlayerControl.Metrics.playButtonEdgeInset
    //button.isHidden = true // Hiding closed captions initially
    return button
  }()
  lazy var chromeCast: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: RBPlayerControl.Assets.closedCaptions)?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.imageView?.tintColor = .white
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = RBPlayerControl.Metrics.playButtonEdgeInset
    button.isEnabled = false // Hiding closed captions initially
    return button
  }()
  lazy var closedCaptions: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: RBPlayerControl.Assets.closedCaptions)?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.imageView?.tintColor = .white
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = RBPlayerControl.Metrics.playButtonEdgeInset
    button.isEnabled = false // Hiding closed captions initially
    return button
  }()
  private lazy var hStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = RBPlayerControl.Metrics.smallSpacing
    return stackView
  }()
  lazy var playPause: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: RBPlayerControl.Assets.pause)?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.imageView?.tintColor = .white
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = RBPlayerControl.Metrics.playButtonEdgeInset
    return button
  }()
  lazy var forward: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: RBPlayerControl.Assets.forward)?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.imageView?.tintColor = .white
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
    return button
  }()
  lazy var rewind: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: RBPlayerControl.Assets.rewind)?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.imageView?.tintColor = .white
    button.imageView?.contentMode = .scaleAspectFit
    button.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
    return button
  }()
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    addControls()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  fileprivate func addTopControls() {
    addTopHStackView()
    addGoogleCast()
    addPictureInPicture()
    addAirplay()
    addClosedCaptions()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    //addTopControls()
  }
  fileprivate func addControls() {
    /*Top controls are for other features such as PIP, Airplay etc*/
    //addTopControls()
    addHStackView()
    addRewind()
    addPlayPause()
    addForward()
  }
  private func addTopHStackView() {
    self.addSubview(topControlsStackView)
    topControlsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    topControlsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    topControlsStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: .zero).isActive = true
    topControlsStackView.heightAnchor.constraint(equalToConstant: 36).isActive = true
    //hStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -controlsViewHeight).isActive = true
  }
  private func addGoogleCast() {
    googleCastButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
    topControlsStackView.addArrangedSubview(googleCastButton)
  }
  private func addPictureInPicture() {
    pictureInPicture.addTarget(self, action: #selector(handlePictureInPictureTapped), for: .touchUpInside)
    pictureInPicture.widthAnchor.constraint(equalToConstant: 40).isActive = true
    topControlsStackView.addArrangedSubview(pictureInPicture)
  }
  private func addAirplay() {
    topControlsStackView.addArrangedSubview(UIView())
    topControlsStackView.addArrangedSubview(UIView())
    topControlsStackView.addArrangedSubview(UIView())
    airplayBtn.addTarget(self, action: #selector(handleAirplayTapped), for: .touchUpInside)
    airplayBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
    topControlsStackView.addArrangedSubview(airplayBtn)
    addAirplayBtn()
  }
  func addAirplayBtn() {
      let routerPickerView = AVRoutePickerView()
      routerPickerView.tintColor = UIColor.white
     // routerPickerView.activeTintColor = Style.Colors.kcpPink
      airplayBtn.addSubview(routerPickerView)
      routerPickerView.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
          routerPickerView.centerXAnchor.constraint(equalTo: airplayBtn.centerXAnchor),
          routerPickerView.centerYAnchor.constraint(equalTo: airplayBtn.centerYAnchor),
          routerPickerView.heightAnchor.constraint(equalTo: airplayBtn.heightAnchor),
          routerPickerView.widthAnchor.constraint(equalTo: airplayBtn.widthAnchor)
      ])
      //airplayBtn.isHidden = !Kcp.isSubscribedUser()
  }
  private func addClosedCaptions() {
    closedCaptions.addTarget(self, action: #selector(handleClosedCaptionTapped), for: .touchUpInside)
    closedCaptions.widthAnchor.constraint(equalToConstant: 40).isActive = true
    topControlsStackView.addArrangedSubview(closedCaptions)
  }
  private func addHStackView() {
    self.addSubview(hStackView)
    //hStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    //hStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    hStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: .zero).isActive = true
    hStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: .zero).isActive = true
    hStackView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.8).isActive = true
    hStackView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    //hStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -controlsViewHeight).isActive = true
  }
  private func addRewind() {
    rewind.addTarget(self, action: #selector(rewindTapped), for: .touchUpInside)
    //rewind.widthAnchor.constraint(equalToConstant: 150).isActive = true
    hStackView.addArrangedSubview(rewind)
  }
  private func addForward() {
    forward.addTarget(self, action: #selector(forwardTapped), for: .touchUpInside)
    //forward.widthAnchor.constraint(equalToConstant: 150).isActive = true
    hStackView.addArrangedSubview(forward)
  }
  private func addPlayPause() {
    playPause.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
    //playPause.widthAnchor.constraint(equalToConstant: 150).isActive = true
    hStackView.addArrangedSubview(playPause)
  }
  @objc private func playPauseTapped(_ sender: UIButton) {
    self.playPauseAction?(sender)
//    if session?.player.timeControlStatus == .playing {
//      session?.player.pause()
//    } else if session?.player.timeControlStatus == .paused  {
//      session?.player.play()
//    } else if session?.player.timeControlStatus == .waitingToPlayAtSpecifiedRate   {
//      session?.player.play()
//    }
  }
  private func setPauseImage() {
    playPause.setImage(UIImage(named: RBPlayerControl.Assets.pause)?.withRenderingMode(.alwaysTemplate), for: .normal)
  }
  private func setPlayImage() {
    playPause.setImage(UIImage(named: RBPlayerControl.Assets.play)?.withRenderingMode(.alwaysTemplate), for: .normal)
  }
  @objc private func handleClosedCaptionTapped(_ sender: UIButton) {
    self.closedCaptionsTapped?(sender)
  }
  @objc private func handlePictureInPictureTapped(_ sender: UIButton) {
    self.pictureInPictureTapped?(sender)
  }
  @objc private func handleAirplayTapped(_ sender: UIButton) {
  }
  @objc private func rewindTapped(_ sender: UIButton) {
    guard let player = self.currentPlayer else{
      return
    }
    let playerCurrentTime = Int(CMTimeGetSeconds(player.currentTime()))
    var newTime = Double(playerCurrentTime - Int(ControlConstants.seekDuration))
    if newTime < 0 {
      newTime = 0
    }
    let seekTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
    self.playbackController?.seek(to: seekTime, completionHandler: { (finished: Bool) in
    })
    self.rewindAction?(sender)
  }
  @objc private func forwardTapped(_ sender: UIButton) {
    guard let player = self.currentPlayer,
          let duration  = player.currentItem?.duration else{
      return
    }
    let playerCurrentTime = Int(CMTimeGetSeconds(player.currentTime()))
    var newTime = Double(playerCurrentTime + Int(ControlConstants.seekDuration))
    if newTime >= CMTimeGetSeconds(duration) {
      newTime = CMTimeGetSeconds(duration)
    }
    let seekTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
    self.playbackController?.seek(to: seekTime, completionHandler: {  (finished: Bool) in
      
    })
    self.forwardAction?(sender)
  }
}
