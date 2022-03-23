import UIKit
import BrightcovePlayerSDK
class OverlaySizeFactory {
  class func setupDimensions(referenceView: UIView, screenMode: BCOVPUIScreenMode) {
    if UIDevice.isPad {
      OverlaySizeFactory.setupDimensionsForIPad(referenceView: referenceView, screenMode: screenMode)
    } else if UIDevice.isPhone {
      OverlaySizeFactory.setupDimensionsForIPhone(referenceView: referenceView, screenMode: screenMode)
    }
  }
  class func setupDimensionsForIPad(referenceView: UIView, screenMode: BCOVPUIScreenMode) {
    if screenMode == .normal { // OK
      if UIDevice.current.orientation.isLandscape {
        OverlaySize.height = (referenceView.frame.width) * 0.15
        OverlaySize.width = (referenceView.frame.width) * 0.30
      } else if UIDevice.current.orientation.isPortrait {
        OverlaySize.height = (referenceView.frame.height) * 0.75
        OverlaySize.width = (referenceView.frame.width) * 0.35
      }
    } else if screenMode == .full {  // OK
      if UIDevice.current.orientation.isLandscape {
        OverlaySize.height = (referenceView.frame.width) * 0.35
        OverlaySize.width = (referenceView.frame.width) * 0.7
      } else if UIDevice.current.orientation.isPortrait {
        OverlaySize.height = (referenceView.frame.height) * 0.35
        OverlaySize.width = (referenceView.frame.width) * 0.7
      }
    }
  }
  class func setupDimensionsForIPhone(referenceView: UIView, screenMode: BCOVPUIScreenMode) {
    if screenMode == .normal { // OK
      if UIDevice.current.orientation.isLandscape {
        OverlaySize.height = (referenceView.frame.width) * 0.30
        OverlaySize.width = (referenceView.frame.width) * 0.50
      } else if UIDevice.current.orientation.isPortrait {
        OverlaySize.height = (referenceView.frame.height) * 0.70
        OverlaySize.width = (referenceView.frame.width) * 0.65
      }
    } else if screenMode == .full {  // OK
      if UIDevice.current.orientation.isLandscape {
        OverlaySize.height = (referenceView.frame.width) * 0.35
        OverlaySize.width = (referenceView.frame.width) * 0.60
      } else if UIDevice.current.orientation.isPortrait {
        OverlaySize.height = (referenceView.frame.width) * 0.55
        OverlaySize.width = (referenceView.frame.width) * 0.7
      }
    }
  }
}
