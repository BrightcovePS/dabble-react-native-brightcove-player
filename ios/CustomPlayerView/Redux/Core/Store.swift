import UIKit
class Store {
    var reducer: Reducer
    var state: State?
    var subscribers: [StoreSubscriber] = []
    
    init(reducer: @escaping Reducer, state: State?) {
        self.reducer = reducer
        self.state = state
    }
    
    func dispatch(action: Action) {
      /// Store state holds the gridview state
      ///The store is also in charge of updating the state based on the action
        state = reducer(action, state)
        
        subscribers.forEach { $0.newState(state: state!) }
    }
    
    func subscribe(_ newSubscriber: StoreSubscriber) {
        subscribers.append(newSubscriber)
    }
    func removeSubscriber(_ subscriber: StoreSubscriber) {
     for (index, value ) in subscribers.enumerated() where value === subscriber {
      if index < subscribers.count {
        self.subscribers.remove(at: index)
      }
    }
  }
}
