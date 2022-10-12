import Foundation
extension PlayerView: AirPlayable {
  func addAirplayObserver() {
    airplayDecorator.addAirplayObserver()
  }
}
