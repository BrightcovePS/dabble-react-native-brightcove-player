import UIKit
import BrightcovePlayerSDK
fileprivate struct OverlaySizeFactoryConstants {
  static let titleHeight: CGFloat = 34
}
class OverlaySizeFactory {
  static var aspectRatio: CGFloat = (9/16)
  static var aspectRatioInverse: CGFloat = (16/9)
  class func setupDimensions(referenceViewCGrect: CGRect, screenMode: BCOVPUIScreenMode) {
    if UIDevice.isPad {
      OverlaySizeFactory.setupDimensionsForIPad(referenceViewCGrect: referenceViewCGrect, screenMode: screenMode)
    } else if UIDevice.isPhone {
      OverlaySizeFactory.setupDimensionsForIPhone(referenceViewCGrect: referenceViewCGrect, screenMode: screenMode)
    }
  }
  class func setupDimensionsForIPad(referenceViewCGrect: CGRect, screenMode: BCOVPUIScreenMode) {
    let widthRatio: CGFloat = 0.7
    let heightRatio: CGFloat = 0.6
    if screenMode == .normal { // OK
      if referenceViewCGrect.height < referenceViewCGrect.width { // take height for landscape
        OverlaySize.height = (referenceViewCGrect.height) * heightRatio + OverlaySizeFactoryConstants.titleHeight
        OverlaySize.width = (referenceViewCGrect.height) * heightRatio * OverlaySizeFactory.aspectRatioInverse
      } else {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = OverlaySize.width * OverlaySizeFactory.aspectRatio + OverlaySizeFactoryConstants.titleHeight
      }
    } else if screenMode == .full {  // OK
      if referenceViewCGrect.height < referenceViewCGrect.width {
        OverlaySize.height = (referenceViewCGrect.height) * 0.5 + OverlaySizeFactoryConstants.titleHeight
        OverlaySize.width = (referenceViewCGrect.height) * 0.5 * OverlaySizeFactory.aspectRatioInverse
      } else  {
        OverlaySize.width = (referenceViewCGrect.width) * 0.65
        OverlaySize.height = OverlaySize.width * OverlaySizeFactory.aspectRatio + OverlaySizeFactoryConstants.titleHeight
      }
    }
  }
  class func setupDimensionsForIPhone(referenceViewCGrect: CGRect, screenMode: BCOVPUIScreenMode) {
    let widthRatio: CGFloat = 0.7
    let heightRatio: CGFloat = 0.6
    if screenMode == .normal { // OK
      if referenceViewCGrect.height < referenceViewCGrect.width { // take height for landscape
        OverlaySize.height = (referenceViewCGrect.height) * heightRatio + OverlaySizeFactoryConstants.titleHeight
        OverlaySize.width = (referenceViewCGrect.height) * heightRatio * OverlaySizeFactory.aspectRatioInverse
      } else {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = OverlaySize.width * OverlaySizeFactory.aspectRatio + OverlaySizeFactoryConstants.titleHeight
      }
    } else if screenMode == .full {  // OK
      if referenceViewCGrect.height < referenceViewCGrect.width {
        OverlaySize.height = (referenceViewCGrect.height) * heightRatio + OverlaySizeFactoryConstants.titleHeight
        OverlaySize.width = (referenceViewCGrect.height) * heightRatio * OverlaySizeFactory.aspectRatioInverse
      } else  {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = OverlaySize.width * OverlaySizeFactory.aspectRatio + OverlaySizeFactoryConstants.titleHeight
      }
    }
  }
}
