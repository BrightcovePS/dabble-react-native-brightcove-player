import UIKit
class CountDownTimer: NSObject {
  static let shared: CountDownTimer = CountDownTimer()
  var internalTimer: Timer?
  var isCancelled: Bool? = false
  var timerFired: (() -> Void)?
  var timerInvalidated: (() -> Void)?
  private override init () {}
  func startTimer() {
    self.internalTimer?.invalidate()
    self.internalTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimerAction), userInfo: nil, repeats: true)
    self.internalTimer?.tolerance = 0.1
  }
  func stopTimer() {
    self.internalTimer?.invalidate()
    self.timerInvalidated?()
    CountDownTimer.shared.isCancelled = false
  }
  @objc func fireTimerAction(sender: AnyObject?){
    self.timerFired?()
  }
}
