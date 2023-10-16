import UIKit
import BrightcovePlayerSDK
import AVKit
import GoogleCast
struct SeekDuration {
    static var timeInterval: Double = 10
}
fileprivate struct TitleConstants {
    static var height: Double = 24
    static var width: Double = 220
    static var font: Double = 14
    static var yOffset: Double = 0
}
struct ControlConstants {
    static let durationFontSize: CGFloat = 14
    static let topStackViewHeight: CGFloat = 36
    static let topStackViewWidth: CGFloat = 180
    static let controlsStackViewHeight: CGFloat = 44
    static let standardButtonWidth: CGFloat = 40
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
    
    var audioEnabled: Bool = false {
        didSet {
            self.audio.isEnabled = audioEnabled
        }
    }
    
    var isMuted: Bool = false {
        didSet {
            if isMuted {
                self.setMuteImage()
            } else {
                self.setUnmuteImage()
            }
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
    weak var playerView: PlayerView!
    weak var playbackController: BCOVPlaybackController?
    weak var session: BCOVPlaybackSession? = nil {
        didSet {
            self.addTitle()
        }
    }
    weak var currentPlayer: AVPlayer?
    var playPauseAction: ((UIButton) -> Void)?
    var rewindAction: ((UIButton) -> Void)?
    var forwardAction: ((UIButton) -> Void)?
    var closedCaptionsTapped: ((UIButton) -> Void)?
    var audioTapped: ((UIButton) -> Void)?
    var muteTapped: ((UIButton) -> Void)?
    var pictureInPictureTapped: ((UIButton) -> Void)?
    var airplayTapped: ((UIButton) -> Void)?
    var closeTapped: ((UIButton) -> Void)?
    var infoTapped: ((UIButton) -> Void)?
    var controlsViewHeight: CGFloat = 0 {
        didSet {
            self.addControls()
        }
    }
    var titleText: String = StringConstants.kEmptyString {
        didSet {
            self.titleLabel.text = " " + titleText
        }
    }
    private lazy var topLeftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        // stackView.spacing = RBPlayerControl.Metrics.smallSpacing
        return stackView
    }()
    private lazy var topControlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        // stackView.spacing = RBPlayerControl.Metrics.smallSpacing
        return stackView
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "This is a title"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: TitleConstants.font, weight: .semibold)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        //label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var infoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: RBPlayerControl.Assets.info, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = RBPlayerControl.Metrics.buttonEdgeInset
        button.isEnabled = true
        return button
    }()
    lazy var googleCastButton: GCKUICastButton = {
        let button = GCKUICastButton()
        button.tintColor = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: RBPlayerControl.Assets.close, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = RBPlayerControl.Metrics.buttonEdgeInset
        button.isEnabled = true
        return button
    }()
    lazy var pictureInPicture: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: RBPlayerControl.Assets.pictureinpicture, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = RBPlayerControl.Metrics.buttonEdgeInset
        button.isEnabled = true
        return button
    }()
    lazy var airplayBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        // button.setImage(UIImage(named: RBPlayerControl.Assets.airplay, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = RBPlayerControl.Metrics.playButtonEdgeInset
        //button.isHidden = true // Hiding closed captions initially
        return button
    }()
    lazy var chromeCast: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: RBPlayerControl.Assets.closedCaptions, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = RBPlayerControl.Metrics.playButtonEdgeInset
        button.isEnabled = false // Hiding closed captions initially
        return button
    }()
    lazy var closedCaptions: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: RBPlayerControl.Assets.closedCaptions, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = RBPlayerControl.Metrics.playButtonEdgeInset
        button.isEnabled = false // Hiding closed captions initially
        return button
    }()
    
    lazy var audio: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: RBPlayerControl.Assets.audio, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
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
        button.setImage(UIImage(named: RBPlayerControl.Assets.pause, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = RBPlayerControl.Metrics.playButtonEdgeInset
        return button
    }()
    lazy var forward: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: RBPlayerControl.Assets.forward, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
        return button
    }()
    lazy var rewind: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: RBPlayerControl.Assets.rewind, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
        return button
    }()
    lazy var mute: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: RBPlayerControl.Assets.unmute, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
        return button
    }()
    //  override init(frame: CGRect) {
    //    super.init(frame: frame)
    //    self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    //    addControls()
    //  }
    init(_ playerView: PlayerView) {
        super.init(frame: .zero)
        self.playerView = playerView
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        addControls()
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    fileprivate func addTopControls() {
//        addTopHStackView()
        addTopLeftStackView()
        addCloseButton()
        configureControlsBasedOnOrientation()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addTopControls()
    }
    fileprivate func addControls() {
        /*Top controls are for other features such as PIP, Airplay etc*/
        addTopControls()
        addHStackView()
        addRewind()
        addPlayPause()
        addForward()
    }
    private func addTopHStackView() {
        self.addSubview(topControlsStackView)
        //topControlsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        topControlsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        topControlsStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: .zero).isActive = true
        topControlsStackView.heightAnchor.constraint(equalToConstant: ControlConstants.topStackViewHeight).isActive = true
        topControlsStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: .zero).isActive = true
        //hStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -controlsViewHeight).isActive = true
    }
    func configureControlsBasedOnOrientation() {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight  {
            configureLandscape()
        } else {
            configurePortrait()
        }
    }
    func clearTopHStackView() {
        topControlsStackView.arrangedSubviews.forEach { eachSubView in
            eachSubView.removeFromSuperview()
        }
    }
    /* To be configured based on project requirements*/
    func configureLandscape() {
        hStackView.isHidden = session == nil
        addTitle()
        clearTopHStackView()
//        addInfoButton()
//        addGoogleCast()
        addClosedCaptions()
        addAudio()
//        addMuteButton()
    }
    /* To be configured based on project requirements*/
    func configurePortrait() {
        hStackView.isHidden = session == nil
        addTitle()
        clearTopHStackView()
//        addInfoButton()
//        addGoogleCast()
//        addPictureInPicture()
//        addAirplay()
        addClosedCaptions()
        addAudio()
//        addMuteButton()
    }
    private func addTopLeftStackView() {
        self.addSubview(topLeftStackView)
//        topControlsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        topLeftStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: .zero).isActive = true
        topLeftStackView.heightAnchor.constraint(equalToConstant: ControlConstants.topStackViewHeight).isActive = true
        topLeftStackView.widthAnchor.constraint(equalToConstant: ControlConstants.standardButtonWidth).isActive = true
    }
    private func addCloseButton() {
        closeButton.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
        closeButton.widthAnchor.constraint(equalToConstant: ControlConstants.standardButtonWidth).isActive = true
        topLeftStackView.addArrangedSubview(closeButton)
    }
    private func removeTitle() {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight  {
            removeTitleLandscape()
        } else {
            removeTitlePortrait()
        }
    }
    private func removeTitlePortrait() {
        titleLabel.removeFromSuperview()
    }
    private func removeTitleLandscape() {
        titleLabel.removeFromSuperview()
    }
    private func addTitle() {
        guard self.session != nil else {
            return
        }
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight  {
            addTitleLandscape()
        } else {
            addTitlePortrait()
        }
        self.titleText = session?.video?.properties[kBCOVVideoPropertyKeyName] as? String ?? StringConstants.kEmptyString
    }
    private func addTitleLandscape() {
       addTitlePortrait()
    }
    private func addTitlePortrait() {
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            titleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.heightAnchor.constraint(equalToConstant: TitleConstants.height),
//            titleLabel.widthAnchor.constraint(equalToConstant: TitleConstants.width)
            ])
    }
    private func addInfoButton() {
        topControlsStackView.addArrangedSubview(UIView())
        infoButton.addTarget(self, action: #selector(handleInfoTapped), for: .touchUpInside)
        infoButton.widthAnchor.constraint(equalToConstant: ControlConstants.standardButtonWidth).isActive = true
        topControlsStackView.addArrangedSubview(infoButton)
    }
    private func addGoogleCast() {
        topControlsStackView.addArrangedSubview(UIView())
        googleCastButton.widthAnchor.constraint(equalToConstant: ControlConstants.standardButtonWidth).isActive = true
        topControlsStackView.addArrangedSubview(googleCastButton)
    }
    private func addPictureInPicture() {
        pictureInPicture.addTarget(self, action: #selector(handlePictureInPictureTapped), for: .touchUpInside)
        pictureInPicture.widthAnchor.constraint(equalToConstant: ControlConstants.standardButtonWidth).isActive = true
        topControlsStackView.addArrangedSubview(pictureInPicture)
    }
    private func addAirplay() {
        airplayBtn.addTarget(self, action: #selector(handleAirplayTapped), for: .touchUpInside)
        airplayBtn.widthAnchor.constraint(equalToConstant: ControlConstants.standardButtonWidth).isActive = true
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
        closedCaptions.widthAnchor.constraint(equalToConstant: ControlConstants.standardButtonWidth).isActive = true
        topControlsStackView.addArrangedSubview(closedCaptions)
    }
    
    private func addAudio() {
        audio.addTarget(self, action: #selector(handleAudioTapped), for: .touchUpInside)
        audio.widthAnchor.constraint(equalToConstant: ControlConstants.standardButtonWidth).isActive = true
        topControlsStackView.addArrangedSubview(audio)
    }
    
    private func addMuteButton() {
        mute.addTarget(self, action: #selector(handleMuteTapped), for: .touchUpInside)
        mute.widthAnchor.constraint(equalToConstant: ControlConstants.standardButtonWidth).isActive = true
        topControlsStackView.addArrangedSubview(mute)
    }
    private func addHStackView() {
        self.addSubview(hStackView)
        //hStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        //hStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        hStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: .zero).isActive = true
        hStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: .zero).isActive = true
        hStackView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor).isActive = true
        hStackView.heightAnchor.constraint(equalToConstant: ControlConstants.controlsStackViewHeight).isActive = true
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
        playPause.setImage(UIImage(named: RBPlayerControl.Assets.pause, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    private func setPlayImage() {
        playPause.setImage(UIImage(named: RBPlayerControl.Assets.play, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    private func setMuteImage() {
        mute.setImage(UIImage(named: RBPlayerControl.Assets.mute, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    private func setUnmuteImage() {
        mute.setImage(UIImage(named: RBPlayerControl.Assets.unmute, in: Bundle(for: CustomOverlayControl.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    @objc  func handleClosedCaptionTapped(_ sender: UIButton) {
        self.closedCaptionsTapped?(sender)
    }
    
    @objc  func handleAudioTapped(_ sender: UIButton) {
        self.audioTapped?(sender)
    }

    
    @objc private func handleMuteTapped(_ sender: UIButton) {
        self.muteTapped?(sender)
    }
    @objc private func handlePictureInPictureTapped(_ sender: UIButton) {
        self.pictureInPictureTapped?(sender)
    }
    @objc private func handleAirplayTapped(_ sender: UIButton) {
    }
    @objc private func handleCloseTapped(_ sender: UIButton) {
        self.closeTapped?(sender)
    }
    @objc private func handleInfoTapped(_ sender: UIButton) {
        self.infoTapped?(sender)
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
