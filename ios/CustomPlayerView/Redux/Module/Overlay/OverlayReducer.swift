import Foundation

class OverlayReducer {
  static let shared = OverlayReducer()
  var store: Store?
  private init() {
    store = Store(reducer: gridViewReducer, state: nil)
  }
  func gridViewReducer(_ action: Action, _ state: State?) -> State {
    var newState = state as? OverlayReduxState ?? OverlayReduxState()
    guard let actionReceived = action as? OverlayAction else { return newState }
    newState.didSelectedState = actionReceived.didSelected
    newState.indexPath = actionReceived.indexPath
    newState.referenceId = actionReceived.referenceId
    newState.videoId = actionReceived.videoId
    newState.actionType = actionReceived.actionType
    return newState
  }
}
