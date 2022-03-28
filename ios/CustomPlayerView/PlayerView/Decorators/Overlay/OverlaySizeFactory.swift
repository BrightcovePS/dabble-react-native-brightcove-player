import UIKit
import BrightcovePlayerSDK
fileprivate struct OverlaySizeFactoryConstants {
  static let titleHeight: CGFloat = 28
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
    if screenMode == .normal { // OK
      let widthRatio: CGFloat = 0.7
      let heightRatio: CGFloat = 0.7
      if referenceViewCGrect.height < referenceViewCGrect.width { // take height for landscape
        OverlaySize.height = ((referenceViewCGrect.height) * heightRatio) + OverlaySizeFactoryConstants.titleHeight
        OverlaySize.width = ((referenceViewCGrect.height) * heightRatio * OverlaySizeFactory.aspectRatioInverse) - OverlaySizeFactoryConstants.titleHeight
      } else {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = ((referenceViewCGrect.width) * widthRatio * OverlaySizeFactory.aspectRatio) + OverlaySizeFactoryConstants.titleHeight
      }
    } else if screenMode == .full {  // OK
      let widthRatio: CGFloat = 0.725
      let heightRatio: CGFloat = 0.55
      if referenceViewCGrect.height < referenceViewCGrect.width {
        OverlaySize.height = ((referenceViewCGrect.height) * heightRatio) + OverlaySizeFactoryConstants.titleHeight
        OverlaySize.width = ((referenceViewCGrect.height) * heightRatio * OverlaySizeFactory.aspectRatioInverse) - OverlaySizeFactoryConstants.titleHeight
      } else  {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = ((referenceViewCGrect.width) * widthRatio * OverlaySizeFactory.aspectRatio) + OverlaySizeFactoryConstants.titleHeight
      }
    }
  }
  class func setupDimensionsForIPhone(referenceViewCGrect: CGRect, screenMode: BCOVPUIScreenMode) {
    if screenMode == .normal { // OK
      let widthRatio: CGFloat = 0.7
      let heightRatio: CGFloat = 0.65
      if referenceViewCGrect.height < referenceViewCGrect.width { // take height for landscape
        OverlaySize.height = ((referenceViewCGrect.height) * heightRatio) + OverlaySizeFactoryConstants.titleHeight
        OverlaySize.width = ((referenceViewCGrect.height) * heightRatio * OverlaySizeFactory.aspectRatioInverse) - OverlaySizeFactoryConstants.titleHeight
      } else {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = ((referenceViewCGrect.width + OverlaySizeFactoryConstants.titleHeight) * widthRatio * OverlaySizeFactory.aspectRatio) + OverlaySizeFactoryConstants.titleHeight
      }
    } else if screenMode == .full {  // OK
      let widthRatio: CGFloat = 0.725
      let heightRatio: CGFloat = 0.75
      if referenceViewCGrect.height < referenceViewCGrect.width {
        OverlaySize.height = ((referenceViewCGrect.height) * heightRatio) + OverlaySizeFactoryConstants.titleHeight
        OverlaySize.width = ((referenceViewCGrect.height) * heightRatio * OverlaySizeFactory.aspectRatioInverse) - OverlaySizeFactoryConstants.titleHeight
      } else  {
        OverlaySize.width = (referenceViewCGrect.width) * widthRatio
        OverlaySize.height = ((referenceViewCGrect.width + OverlaySizeFactoryConstants.titleHeight) * widthRatio * OverlaySizeFactory.aspectRatio) + OverlaySizeFactoryConstants.titleHeight
      }
    }
  }
}
