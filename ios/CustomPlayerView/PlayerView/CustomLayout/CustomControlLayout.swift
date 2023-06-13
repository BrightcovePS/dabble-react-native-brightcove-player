import UIKit
import BrightcovePlayerSDK
fileprivate struct PlayerControlConstants {
  static let seekDuration: Double = 15
  static let durationLabelWidth: CGFloat = 50
}
class CustomControlLayout: NSObject {
  var screenModeButton: UIButton!
  weak var playerView: PlayerView?
  var fullScreen: Bool = false
  var handleForwardTap: (() -> Void)?
  var handleRewindTap: (() -> Void)?
  weak var playbackController: BCOVPlaybackController?
  weak var session: BCOVPlaybackSession? = nil
  weak var currentPlayer: AVPlayer?
  var currentLayoutLive = false
    var closedCaptions:UIButton?
    var audioCaptions:UIButton?
    
    func setLayout(isLive:Bool) -> (BCOVPUIControlLayout?, BCOVPUILayoutView?) {
        currentLayoutLive = isLive
    // Create a new control for each tag.
    // Controls are packaged inside a layout view.
    let playButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonPlayback, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)!
    let jumpBackButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonJumpBack, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)!
      
    let currentTimeLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .labelCurrentTime, width: PlayerControlConstants.durationLabelWidth, elasticity: 0.0)
    let liveLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonLive, width: PlayerControlConstants.durationLabelWidth, elasticity: 0.0)

    let progressLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .sliderProgress, width: kBCOVPUILayoutUseDefaultValue, elasticity: 1.0)
    if let progressSlider = progressLayoutView?.subviews.first as? UISlider {
      if let progressColor = self.playerView?.progressTintColor {
      progressSlider.minimumTrackTintColor = UIColor().hexStringToUIColor(hex: progressColor)
      }
      progressSlider.setThumbImage(UIImage(named: RBPlayerControl.Assets.slider, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withColor(.white), for: .normal)
      progressSlider.setThumbImage(UIImage(named: RBPlayerControl.Assets.slider, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withColor(.white), for: .normal)
    }
    let durationLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .labelDuration, width: PlayerControlConstants.durationLabelWidth, elasticity: 0.0)
    let closedCaptionLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonClosedCaption, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)!
    //closedCaptionLayoutView?.isRemoved = true // Hide until it's explicitly needed.
    let screenModeLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonScreenMode, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)!
    let externalRouteLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewExternalRoute, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)
    //externalRouteLayoutView?.isRemoved = true // Hide until it's explicitly needed.
    let spacerLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: 1.0, elasticity: 1.0)
    let closedCaptions = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: 40.0, elasticity: 0.0)
    let audioCaptions = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: 40.0, elasticity: 0.0)
    let ffButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0)
    let rewindButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0)
    let rotateButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0)
    let timeSeparatorLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .labelTimeSeparator, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0)
    let fullScreenButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0)
    let pipButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonPictureInPicture, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0)
    // Add UIButton to layout.
    if let rotateLayoutButton = rotateButtonLayoutView {
      screenModeButton = UIButton(frame: rotateLayoutButton.frame)
      screenModeButton.frame = rotateLayoutButton.frame
      screenModeButton.frame.size = CGSize(width: 30, height: 30)
      screenModeButton.center = CGPoint(x: rotateLayoutButton.frame.size.width / 2,
                                y: rotateLayoutButton.frame.size.height / 4)
      screenModeButton.setImage(UIImage(named: RBPlayerControl.Assets.fullscreen, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
      screenModeButton.imageView?.tintColor = .white
      screenModeButton.addTarget(self, action: #selector(fullScreenRotateTapped(_:)), for: .touchUpInside)
      //button.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
      rotateLayoutButton.addSubview(screenModeButton)
    }
    if let ffButtonLayoutView = ffButtonLayoutView {
      let button = UIButton(frame: ffButtonLayoutView.frame)
      button.frame = closedCaptionLayoutView.frame
      button.frame.size = CGSize(width: 30, height: 30)
      button.center = CGPoint(x: closedCaptionLayoutView.frame.size.width / 2,
                                y: closedCaptionLayoutView.frame.size.height / 4)
      button.setImage(UIImage(named: RBPlayerControl.Assets.forward, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
      button.imageView?.tintColor = .white
      button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
      //button.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
      ffButtonLayoutView.addSubview(button)
    }
    if let rewindButtonLayoutView = rewindButtonLayoutView {
      let button = UIButton(frame: rewindButtonLayoutView.frame)
      button.frame = closedCaptionLayoutView.frame
      button.frame.size = CGSize(width: 30, height: 30)
      button.center = CGPoint(x: closedCaptionLayoutView.frame.size.width / 2,
                                y: closedCaptionLayoutView.frame.size.height / 4)
      button.setImage(UIImage(named: RBPlayerControl.Assets.rewind, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
      button.imageView?.tintColor = .white
      button.addTarget(self, action: #selector(btnRewindTapped(_:)), for: .touchUpInside)
      //button.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
      rewindButtonLayoutView.addSubview(button)
    }
    if let pipbutton = pipButtonLayoutView?.subviews.first as? UIButton {
      pipbutton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
      pipbutton.setImage(UIImage(named: RBPlayerControl.Assets.pictureinpicture, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
      pipbutton.imageView?.contentMode = .scaleAspectFit
     // pipbutton.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
    }
        
        if let liveButton = liveLayoutView?.subviews.first as? UIButton {
          //button.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
            liveButton.setTitleColor(.white, for: .normal)
            liveButton.setTitleColor(.white, for: .focused)
            liveButton.setTitleColor(.white, for: .highlighted)
            liveButton.setTitleColor(.white, for: .selected)

            liveButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            liveButton.setTitle("  LIVE", for: .normal)
            let point = UILabel(frame:  CGRect(x: 5, y: 5, width: 6, height: 6))
            point.text = "•"
            point.textColor = .red
            liveButton.addSubview(point)
        }
        
        if let closedCaptions = closedCaptions {
           let button = UIButton(frame: CGRect(x: 0, y:-5, width: 25, height: 25))
            button.setImage(UIImage(named: RBPlayerControl.Assets.closedCaptions, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.isHidden = true
            button.imageView?.tintColor = .white
            if let currentClosedCaptions = self.closedCaptions {
                closedCaptions.addSubview(currentClosedCaptions)
            }else {
                self.closedCaptions = button
                closedCaptions.addSubview(button)
            }
            
        }
        
        if let audioCaptions = audioCaptions {
           let button = UIButton(frame: CGRect(x: 0, y:-5, width: 25, height: 25))
            button.setImage(UIImage(named: RBPlayerControl.Assets.audio, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.tintColor = .white
            button.isHidden = true
            if let currentAudioCaptions = self.audioCaptions {
                audioCaptions.addSubview(currentAudioCaptions)
            }else {
                self.audioCaptions = button
                audioCaptions.addSubview(button)
            }
           
        }
        
//    if let fullScreenButtonLayoutView = fullScreenButtonLayoutView {
//      screenModeButton = UIButton(frame: fullScreenButtonLayoutView.frame)
//      screenModeButton.frame = fullScreenButtonLayoutView.frame
//      screenModeButton.frame.size = CGSize(width: 30, height: 30)
//      screenModeButton.center = CGPoint(x: fullScreenButtonLayoutView.frame.size.width / 2,
//                                y: fullScreenButtonLayoutView.frame.size.height / 2)
//      screenModeButton.setImage(UIImage(named: RBPlayerControl.Assets.fullscreen, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
//      screenModeButton.imageView?.tintColor = .white
//      screenModeButton.addTarget(self, action: #selector(fullScreenTapped(_:)), for: .touchUpInside)
//      //button.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
//      fullScreenButtonLayoutView.addSubview(screenModeButton)
//    }
    if let ccbutton = closedCaptionLayoutView.subviews.first as? UIButton {
      ccbutton.frame = closedCaptionLayoutView.frame
      ccbutton.frame.size = CGSize(width: 30, height: 30)
      ccbutton.center = CGPoint(x: closedCaptionLayoutView.frame.size.width / 2,
                                y: closedCaptionLayoutView.frame.size.height / 2)
      ccbutton.setImage(UIImage(named: RBPlayerControl.Assets.closedCaptions, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
      ccbutton.imageView?.tintColor = .white
    }
    if let playbutton = playButtonLayoutView.subviews.first as? UIButton {
      playbutton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    }
    // Configure the standard layout lines. landscape
    let standardLayoutLine1 = [currentTimeLayoutView, progressLayoutView, durationLayoutView, externalRouteLayoutView, pipButtonLayoutView, rotateButtonLayoutView, screenModeLayoutView]
    
    // Configure the compact layout lines.
    //compact for portrait
        let maasCompactLayoutLine1 = isLive ? [liveLayoutView, progressLayoutView,closedCaptions, audioCaptions, screenModeLayoutView]:[currentTimeLayoutView,progressLayoutView, durationLayoutView, closedCaptions,audioCaptions,screenModeLayoutView]
//    let maasCompactLayoutLine2 = [externalRouteLayoutView,spacerLayoutView,spacerLayoutView,rotateButtonLayoutView, screenModeLayoutView]
    let compactLayoutLines = [[playButtonLayoutView],maasCompactLayoutLine1,[]]
      playButtonLayoutView.isHidden = true
    // Put the two layout lines into a single control layout object.
    let layout =  BCOVPUIControlLayout(standardControls: compactLayoutLines, compactControls: compactLayoutLines)
    layout?.controlBarHeight = 17
        
        
    return (layout, playButtonLayoutView)
  }
    
    
    
  @objc func buttonTapped(_ sender: UIButton) {
    self.forwardTapped()
  }
  @objc func btnRewindTapped(_ sender: UIButton) {
    self.rewindTapped()
  }
  private func forwardTapped() {
    guard
      let player = self.currentPlayer,
      let duration  = player.currentItem?.duration else{
      return
    }
    let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
    var newTime = playerCurrentTime + ControlConstants.seekDuration
    if newTime >= CMTimeGetSeconds(duration) {
      newTime = CMTimeGetSeconds(duration)
    }
    let seekTime: CMTime = CMTimeMake(value: Int64(newTime.rounded(.towardZero) * 1000 as Float64), timescale: 1000)
    self.playbackController?.seek(to: seekTime, completionHandler: {  (finished: Bool) in
    })
  }
  private func rewindTapped() {
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
  }
  @objc func fullScreenRotateTapped(_ sender: UIButton) {
    if UIDevice.current.orientation.isPortrait {
      let value = UIInterfaceOrientation.landscapeRight.rawValue
      UIDevice.current.setValue(value, forKey: "orientation")
    } else {
      let value = UIInterfaceOrientation.portrait.rawValue
      UIDevice.current.setValue(value, forKey: "orientation")
    }
  }
  @objc private func fullScreenTapped(_ sender: UIButton) {
    if UIDevice.current.orientation.isLandscape {
      if !fullScreen
      {
        fullScreen = true
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
      }
      else
      {
        fullScreen = false
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
      }
    }
    else{
      print(fullScreen)
      if !fullScreen
      {
        fullScreen = true
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
      }
      else
      {
        fullScreen = false
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
      }
    }
  }
  func forceDefaultFullScreen() {
    fullScreen = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0) { self.playerView?.performScreenTransition(with: .full)
    }
  }
  func setupLandscapeUI() {
    self.screenModeButton.setImage(UIImage(named: RBPlayerControl.Assets.fullscreenexit, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
  }
  func setupPortraitUI() {
    self.screenModeButton.setImage(UIImage(named: RBPlayerControl.Assets.fullscreen, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
  }
  func forceFullScreen() {
    fullScreen = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0) { self.playerView?.performScreenTransition(with: .full)
      self.screenModeButton.setImage(UIImage(named: RBPlayerControl.Assets.fullscreenexit, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
  }
  func forcePortrait() {
    fullScreen = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0) { self.playerView?.performScreenTransition(with: .normal)
      self.screenModeButton.setImage(UIImage(named: RBPlayerControl.Assets.fullscreen, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
  }
}
extension UIImage {
    func withColor(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        // 1
        let drawRect = CGRect(x: 0,y: 0,width: size.width,height: size.height)
        // 2
        color.setFill()
        UIRectFill(drawRect)
        // 3
        draw(in: drawRect, blendMode: .destinationIn, alpha: 1)

        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
}
