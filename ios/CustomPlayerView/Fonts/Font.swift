import Foundation
struct Font {
  static var redbullBold = "BullText-Bold"
  static var redbullRegular = "BullText-Regular"
  static var fontType = Font.redbullRegular
  static var currentFont: FontFamily = .redbullRegular {
    didSet {
      Font.setFont()
    }
  }
  static func setFont() {
    switch Font.currentFont {
    case FontFamily.redbullBold, FontFamily.redbullRegular:
      Font.fontType =  Font.currentFont.rawValue
    case .invalidFont:
      Font.fontType = Font.redbullRegular
    }
  }
}
enum FontFamily: String {
  case redbullBold = "BullText-Bold"
  case redbullRegular = "BullText-Regular"
  case invalidFont
}
