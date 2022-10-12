import UIKit
public extension UIFont {
  private static func registerFont(withName name: String, fileExtension: String) {
    let frameworkBundle = Bundle(for: PlayerView.self)
    guard let pathForResourceString = frameworkBundle.path(forResource: name, ofType: fileExtension) else { return }
    guard let fontData = NSData(contentsOfFile: pathForResourceString) else { return }
    let dataProvider = CGDataProvider(data: fontData)
    let fontRef = CGFont(dataProvider!)
    var errorRef: Unmanaged<CFError>? = nil
    if (CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false) {
      print("Error registering font")
    }
  }
  static func loadFonts() {
    registerFont(withName: "BullText-Bold", fileExtension: "ttf")
    registerFont(withName: "BullText-Regular", fileExtension: "ttf")
  }
}
