import Foundation
protocol StoreSubscriber: AnyObject {
    func newState(state: State)
}
