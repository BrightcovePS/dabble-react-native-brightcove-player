import UIKit
struct OverlayReduxState: State {
  var didSelectedState: Bool = false
  var indexPath: IndexPath? = nil
  var referenceId: String?
  var videoId: String?
  var actionType: ActionType? = .none
}
