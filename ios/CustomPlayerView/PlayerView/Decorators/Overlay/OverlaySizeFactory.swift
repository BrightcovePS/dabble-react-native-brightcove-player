import UIKit
import BrightcovePlayerSDK
fileprivate struct OverlaySizeFactoryConstants {
  static let titleHeight: CGFloat = 34
}
class OverlaySizeFactory {
  static var aspectRatio: CGFloat = (9/16)
  class func setupDimensions(referenceViewCGrect: CGRect, screenMode: BCOVPUIScreenMode) {
    if UIDevice.isPad {
      OverlaySizeFactory.setupDimensionsForIPad(referenceViewCGrect: referenceViewCGrect, screenMode: screenMode)
    } else if UIDevice.isPhone {
      OverlaySizeFactory.setupDimensionsForIPhone(referenceViewCGrect: referenceViewCGrect, screenMode: screenMode)
    }
  }
  class func setupDimensionsForIPad(referenceViewCGrect: CGRect, screenMode: BCOVPUIScreenMode) {
    let widthRatio: CGFloat = 0.7
    if screenMode == .normal { // OK
      if UIDevice.current.orientation.isLandscape {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = OverlaySize.width * OverlaySizeFactory.aspectRatio + OverlaySizeFactoryConstants.titleHeight
      } else {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = OverlaySize.width * OverlaySizeFactory.aspectRatio + OverlaySizeFactoryConstants.titleHeight
      }
    } else if screenMode == .full {  // OK
      if UIDevice.current.orientation.isLandscape {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = OverlaySize.width * OverlaySizeFactory.aspectRatio + OverlaySizeFactoryConstants.titleHeight
      } else {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = OverlaySize.width * OverlaySizeFactory.aspectRatio + OverlaySizeFactoryConstants.titleHeight
      }
    }
  }
  class func setupDimensionsForIPhone(referenceViewCGrect: CGRect, screenMode: BCOVPUIScreenMode) {
    let widthRatio: CGFloat = 0.7
    if screenMode == .normal { // OK
      if UIDevice.current.orientation.isLandscape {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = OverlaySize.width * OverlaySizeFactory.aspectRatio + OverlaySizeFactoryConstants.titleHeight
      } else {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = OverlaySize.width * OverlaySizeFactory.aspectRatio + OverlaySizeFactoryConstants.titleHeight
      }
    } else if screenMode == .full {  // OK
      if UIDevice.current.orientation.isLandscape {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = OverlaySize.width * OverlaySizeFactory.aspectRatio + OverlaySizeFactoryConstants.titleHeight
      } else  {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = OverlaySize.width * OverlaySizeFactory.aspectRatio + OverlaySizeFactoryConstants.titleHeight
      }
    }
  }
}
