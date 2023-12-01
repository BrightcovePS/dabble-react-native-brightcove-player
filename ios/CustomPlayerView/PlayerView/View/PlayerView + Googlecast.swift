//import Foundation
//import GoogleCast
//import BrightcoveGoogleCast;
//
//extension PlayerView: GoogleCastable {
//  func configureCastDecorator() {
//    googleCastDecorator.configureCastDecorator()
//  }
//  func installViewController(_ viewController: UIViewController?, inContainerView containerView: UIView) {
//    if let viewController = viewController {
//      viewController.view.frame = containerView.bounds
//      containerView.addSubview(viewController.view)
//    }
//  }
//  func addMediaView() {
//    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
//      mediaView = UIView(frame: CGRect(x: 0, y: rootVC.view.frame.height - 70 - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!, width: rootVC.view.frame.width, height: 70))
//      rootVC.view.addSubview(mediaView)
//    }
//  }
//}
//extension PlayerView: GCKLoggerDelegate {
//  
//}
//extension PlayerView: GCKUIMiniMediaControlsViewControllerDelegate {
//  public func miniMediaControlsViewController(_ miniMediaControlsViewController: GCKUIMiniMediaControlsViewController, shouldAppear: Bool) {
//    print("mini del", shouldAppear)
//  }
//}
