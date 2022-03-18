import UIKit
import BrightcovePlayerSDK
fileprivate struct ControlConstants {
  static let seekDuration: Double = 15
}
class CustomControlLayout: NSObject {
  var screenModeButton: UIButton!
  weak var playerView: PlayerView?
  var fullScreen: Bool = false
  var handleForwardTap: (() -> Void)?
  weak var playbackController: BCOVPlaybackController?
  weak var session: BCOVPlaybackSession? = nil
  weak var currentPlayer: AVPlayer?
  func setLayout() -> (BCOVPUIControlLayout?, BCOVPUILayoutView?) {
    // Create a new control for each tag.
    // Controls are packaged inside a layout view.
    let playButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonPlayback, width: .zero, elasticity: 0.0)
    playButtonLayoutView?.isHidden = true
    let jumpBackButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonJumpBack, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)
    let currentTimeLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .labelCurrentTime, width: 50, elasticity: 0.0)
    let progressLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .sliderProgress, width: kBCOVPUILayoutUseDefaultValue, elasticity: 1.0)
    let durationLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .labelDuration, width: 50, elasticity: 0.0)
    let closedCaptionLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonClosedCaption, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)!
    //closedCaptionLayoutView?.isRemoved = true // Hide until it's explicitly needed.
    let screenModeLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonScreenMode, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)
    let externalRouteLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewExternalRoute, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0.0)
    //externalRouteLayoutView?.isRemoved = true // Hide until it's explicitly needed.
    let spacerLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity: 1.0)
    let ffButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0)
    let timeSeparatorLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .labelTimeSeparator, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0)
    let fullScreenButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .viewEmpty, width: kBCOVPUILayoutUseDefaultValue, elasticity: 0)
    let pipButtonLayoutView = BCOVPUIBasicControlView.layoutViewWithControl(from: .buttonPictureInPicture, width: 0, elasticity: 0)
    pipButtonLayoutView?.heightAnchor.constraint(equalToConstant: 0).isActive = true
    pipButtonLayoutView?.widthAnchor.constraint(equalToConstant: 0).isActive = true
    pipButtonLayoutView?.frame = .zero
    // Add UIButton to layout.
    if let ffButtonLayoutView = ffButtonLayoutView {
      let button = UIButton(frame: ffButtonLayoutView.frame)
      button.setTitleColor(.green, for: .normal)
      button.setTitleColor(.yellow, for: .highlighted)
      button.setImage(UIImage(named: RBPlayerControl.Assets.forward)?.withRenderingMode(.alwaysTemplate), for: .normal)
      button.imageView?.tintColor = .white
      button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
      button.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
      ffButtonLayoutView.addSubview(button)
    }
    if let fullScreenButtonLayoutView = fullScreenButtonLayoutView {
      screenModeButton = UIButton(frame: fullScreenButtonLayoutView.frame)
      screenModeButton.frame = closedCaptionLayoutView.frame
      screenModeButton.frame.size = CGSize(width: 30, height: 30)
      screenModeButton.center = CGPoint(x: closedCaptionLayoutView.frame.size.width / 2,
                                y: closedCaptionLayoutView.frame.size.height / 2)
      screenModeButton.setImage(UIImage(named: RBPlayerControl.Assets.fullscreen)?.withRenderingMode(.alwaysTemplate), for: .normal)
      screenModeButton.imageView?.tintColor = .white
      screenModeButton.addTarget(self, action: #selector(fullScreenTapped(_:)), for: .touchUpInside)
      //button.imageEdgeInsets = RBPlayerControl.Metrics.forwardEdgeInset
      fullScreenButtonLayoutView.addSubview(screenModeButton)
    }
    if let ccbutton = closedCaptionLayoutView.subviews.first as? UIButton {
      ccbutton.frame = closedCaptionLayoutView.frame
      ccbutton.frame.size = CGSize(width: 30, height: 30)
      ccbutton.center = CGPoint(x: closedCaptionLayoutView.frame.size.width / 2,
                                y: closedCaptionLayoutView.frame.size.height / 2)
      ccbutton.setImage(UIImage(named: RBPlayerControl.Assets.closedCaptions)?.withRenderingMode(.alwaysTemplate) , for: .normal)
      ccbutton.imageView?.tintColor = .white
    }
    // Configure the standard layout lines. landscape
    let standardLayoutLine1 = [playButtonLayoutView, currentTimeLayoutView,timeSeparatorLayoutView, durationLayoutView, progressLayoutView, screenModeLayoutView]
  
    let standardLayoutLine2 = [playButtonLayoutView, jumpBackButtonLayoutView, ffButtonLayoutView, spacerLayoutView, closedCaptionLayoutView, screenModeLayoutView, externalRouteLayoutView]
    let standardLayoutLines = [standardLayoutLine1]
    
    // Configure the compact layout lines.
    //compact for portrait
    let compactLayoutLine1 = [playButtonLayoutView,currentTimeLayoutView, timeSeparatorLayoutView, durationLayoutView, progressLayoutView, screenModeLayoutView]
    let compactLayoutLine2 = [playButtonLayoutView, jumpBackButtonLayoutView, ffButtonLayoutView, spacerLayoutView, closedCaptionLayoutView, screenModeLayoutView, externalRouteLayoutView]
    let compactLayoutLines = [compactLayoutLine1]
    
    // Put the two layout lines into a single control layout object.
    let layout = BCOVPUIControlLayout(standardControls: standardLayoutLines, compactControls: compactLayoutLines)
    layout?.horizontalItemSpacing = 0
    return (layout, playButtonLayoutView)
  }
  @objc func buttonTapped(_ sender: UIButton) {
    self.forwardTapped()
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
  func forceFullScreen() {
    fullScreen = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0) { self.playerView?.performScreenTransition(with: .full)
      self.screenModeButton.setImage(UIImage(named: RBPlayerControl.Assets.fullscreenexit)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
  }
  func forcePortrait() {
    fullScreen = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 0) { self.playerView?.performScreenTransition(with: .normal)
      self.screenModeButton.setImage(UIImage(named: RBPlayerControl.Assets.fullscreen)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }
  }
}
