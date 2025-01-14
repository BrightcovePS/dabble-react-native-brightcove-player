import UIKit
fileprivate struct TimerViewConstants {
  static let cancelTxt = "Cancel"
  static let timerWidth: CGFloat = 10
  static let timerHeight: CGFloat = 30
  static let cancelWidth: CGFloat = 60
  static let cancelHeight: CGFloat = 30
}
class TimerView: UIView {
  var progressCompleted: (() -> Void)?
  var runCount = 0
  // TODO:- To remove the local timer instance
  var timer: Timer?
  private lazy var timerLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "\(runCount)"
    label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    label.textColor = .white
    return label
  }()
  lazy var cancelTimerButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(TimerViewConstants.cancelTxt, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    button.addTarget(self, action: #selector(handleCancelTimerTapped), for: .touchUpInside)
    return button
  }()
  init(timerDuration: TimeInterval = TimerConstants.nextVideoThumbnailDuration) {
    runCount = Int(timerDuration)
    super.init(frame: .zero)
    self.translatesAutoresizingMaskIntoConstraints = false
    if !(CountDownTimer.shared.isCancelled ?? false) {
    addTimerLabel()
    addCancelButton()
    scheduleTimer()
    }
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  private func addTimerLabel() {
    self.addSubview(timerLabel)
    timerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: .zero).isActive = true
    timerLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: .zero).isActive = true
    timerLabel.widthAnchor.constraint(equalToConstant: TimerViewConstants.timerWidth).isActive = true
    timerLabel.heightAnchor.constraint(equalToConstant: TimerViewConstants.timerHeight).isActive = true
  }
  private func addCancelButton() {
    self.addSubview(cancelTimerButton)
    cancelTimerButton.leadingAnchor.constraint(equalTo: self.timerLabel.trailingAnchor, constant: .zero).isActive = true
    cancelTimerButton.centerYAnchor.constraint(equalTo: self.timerLabel.centerYAnchor).isActive = true
    cancelTimerButton.widthAnchor.constraint(equalToConstant: TimerViewConstants.cancelWidth).isActive = true
    cancelTimerButton.heightAnchor.constraint(equalToConstant: TimerViewConstants.cancelHeight).isActive = true
  }
  @objc private func handleCancelTimerTapped() {
    CountDownTimer.shared.stopTimer()
    self.timerLabel.isHidden = true
    self.cancelTimerButton.isHidden = true
    CountDownTimer.shared.isCancelled = true
  }
  private func scheduleTimer() {
    CountDownTimer.shared.startTimer()
    CountDownTimer.shared.timerFired = { [weak self] in
      guard let self = self else {
        return
      }
      self.runCount -= 1
      if self.runCount == 0 {
        CountDownTimer.shared.stopTimer()
        self.timerLabel.isHidden = true
        self.runCount = Int(TimerConstants.nextVideoThumbnailDuration)
        self.progressCompleted?()
      }
      self.timerLabel.text = "\(self.runCount)"
    }
    CountDownTimer.shared.timerInvalidated = { [weak self] in
      guard let self = self else {
        return
      }
      self.runCount = Int(TimerConstants.nextVideoThumbnailDuration)
    }
  }
  deinit {
//    self.timer?.invalidate()
//    CountDownTimer.shared.stopTimer()
  }
}
