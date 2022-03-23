import UIKit
enum ActionType {
  case overlaySelection
  case closeOverlay
}
struct OverlayAction: Action {
  let didSelected: Bool
  let indexPath: IndexPath
  var referenceId: String?
  var videoId: String?
  var actionType: ActionType
}
