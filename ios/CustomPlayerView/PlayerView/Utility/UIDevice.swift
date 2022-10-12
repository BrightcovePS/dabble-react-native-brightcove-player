import UIKit
public extension UIDevice {
  
  class var isPhone: Bool {
    return UIDevice.current.userInterfaceIdiom == .phone
  }
  
  class var isPad: Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
  }
  
  class var isTV: Bool {
    return UIDevice.current.userInterfaceIdiom == .tv
  }
  
  class var isCarPlay: Bool {
    return UIDevice.current.userInterfaceIdiom == .carPlay
  }
  class var isScreenLandscape: Bool {
    UIScreen.main.bounds.width > UIScreen.main.bounds.height
  }
  class var isScreenPortrait: Bool {
    UIScreen.main.bounds.height > UIScreen.main.bounds.width
  }
}
