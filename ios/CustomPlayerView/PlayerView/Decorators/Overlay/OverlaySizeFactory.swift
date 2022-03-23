import UIKit
import BrightcovePlayerSDK
fileprivate struct OverlaySizeFactoryConstants {
  static let titleHeight: CGFloat = 30
}
class OverlaySizeFactory {
  class func setupDimensions(referenceViewCGrect: CGRect, screenMode: BCOVPUIScreenMode) {
    if UIDevice.isPad {
      OverlaySizeFactory.setupDimensionsForIPad(referenceViewCGrect: referenceViewCGrect, screenMode: screenMode)
    } else if UIDevice.isPhone {
      OverlaySizeFactory.setupDimensionsForIPhone(referenceViewCGrect: referenceViewCGrect, screenMode: screenMode)
    }
  }
  class func setupDimensionsForIPad(referenceViewCGrect: CGRect, screenMode: BCOVPUIScreenMode) {
    if screenMode == .normal { // OK
      if UIDevice.current.orientation.isLandscape {
        OverlaySize.width = (referenceViewCGrect.width) * 0.8
        OverlaySize.height = OverlaySize.width * (9/16) + OverlaySizeFactoryConstants.titleHeight
      } else if UIDevice.current.orientation.isPortrait {
        OverlaySize.width = (referenceViewCGrect.width) * 0.8
        OverlaySize.height = OverlaySize.width * (9/16) + OverlaySizeFactoryConstants.titleHeight
      }
    } else if screenMode == .full {  // OK
      if UIDevice.current.orientation.isLandscape {
        OverlaySize.width = (referenceViewCGrect.width) * 0.7
        OverlaySize.height = OverlaySize.width * (9/16) + OverlaySizeFactoryConstants.titleHeight
      } else if UIDevice.current.orientation.isPortrait {
        OverlaySize.width = (referenceViewCGrect.width) * 0.7
        OverlaySize.height = OverlaySize.width * (9/16) + OverlaySizeFactoryConstants.titleHeight
      }
    }
  }
  class func setupDimensionsForIPhone(referenceViewCGrect: CGRect, screenMode: BCOVPUIScreenMode) {
    if screenMode == .normal { // OK
      if UIDevice.current.orientation.isLandscape {
        OverlaySize.width = (referenceViewCGrect.width) * 0.8
        OverlaySize.height = OverlaySize.width * (9/16) + OverlaySizeFactoryConstants.titleHeight
      } else if UIDevice.current.orientation.isPortrait {
        OverlaySize.width = (referenceViewCGrect.width) * 0.8
        OverlaySize.height = OverlaySize.width * (9/16) + OverlaySizeFactoryConstants.titleHeight
      }
    } else if screenMode == .full {  // OK
      if UIDevice.current.orientation.isLandscape {
        OverlaySize.width = (referenceViewCGrect.width) * 0.7
        OverlaySize.height = OverlaySize.width * (9/16) + OverlaySizeFactoryConstants.titleHeight
      } else if UIDevice.current.orientation.isPortrait {
        OverlaySize.width = (referenceViewCGrect.width) * 0.7
        OverlaySize.height = OverlaySize.width * (9/16) + OverlaySizeFactoryConstants.titleHeight
      }
    }
  }
}
