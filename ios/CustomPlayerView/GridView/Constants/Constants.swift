import UIKit
extension Notification.Name {
    static let ScreenMode = Notification.Name("ScreenMode")
}
struct Constants {
  static var hasNotch: Bool {
    if #available(iOS 11.0, *) {
      let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
      return keyWindow?.safeAreaInsets.bottom ?? 0 > 0
    }
    return false
  }
}
struct CTAOverlayConstants {
  static let ctaButtonEdgeInset: CGFloat = 5
  static let ctaInfoIconSize: CGFloat = 20
}
struct RecommendationOverlayConstants {
  static let kRecommendationClosebuttonWidth: CGFloat = 44
  static let kRecommendationClosebuttonHeight: CGFloat = 44
  static let kRecommendationOverlayThumbNailWidth: CGFloat = 0
  static let kRecommendationOverlayThumbNailHeight: CGFloat = 125
  static let kRecommendationOverlayURLLeading: CGFloat = 40
  static let kRecommendationOverlayURLWidth: CGFloat = 0
  static let kRecommendationOverlayTitleBottom: CGFloat = -7.5
  static let kRecommendationOverlayURLHeight: CGFloat = RecommendationOverlayConstants.kRecommendationOverlayThumbNailHeight/2
  static let kRecommendationOverlayItemWidth: CGFloat = 210
  static let kRecommendationOverlayItemHeight: CGFloat = 125
  static var kRecommendationOverlayWidth: CGFloat {
    UIScreen.main.bounds.width
  }
  static let kRecommendationOverlayHeight: CGFloat = 125
  static let kRecommendationOverlayLeading: CGFloat = 10
  static let kRecommendationOverlayTrailing: CGFloat = -10
  static let kRecommendationOverlayTop: CGFloat = 10
  static let kRecommendationOverlayBottom: CGFloat = -88 // has to be -20
  static let kRecommendationOverlayPlayWidth: CGFloat = 28
  static let kRecommendationOverlayPlayHeight: CGFloat = 28
  static let kRecommendationOverlayPlayLeading: CGFloat = 7.5
  static var kControlsViewHeight: CGFloat = 88
  static var kControlsViewHeightDefault: CGFloat = 88
  static var kControlInset: CGFloat {
    if RecommendationOverlayConstants.isFullScreen && Constants.hasNotch {
      return 35
    } else {
      return 0
    }
  }
  static var isFullScreen: Bool = false
}
struct StringConstants {
  static let kEmptyString = ""
}
struct PlayerConstants {
  static let kVideoContainerTop: CGFloat = 20
}
struct Assets {
  static var playImage = "play"
  static var infoImage = "info"
  static var linkoutImage = "linkout"
  static var close = "close"
}
struct Colors {
  static var ctaFontColor = "#444a5a"
  static var ctaBackground = "#b0b7c1"
}
struct MedataDataKeys {
  static var id = "id"
  static var metadata = "metadata"
}
struct Fonts {
  static var sofiaProMedium = "sofiapro-medium"
  static var sofiaProBold = "sofiapro-bold"
}
