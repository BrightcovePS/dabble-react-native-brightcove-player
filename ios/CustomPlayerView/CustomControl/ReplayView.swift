//
//  ReplayView.swift
//  react-native-brightcove-player
//
//  Created by jenix_gnanadhas on 07/11/23.
//

import Foundation
import UIKit
enum ReplayOrientation {
  case landscape
  case portrait
}
struct ReplayViewContansts {
  static let kReplay = "Replay"
  static let kHWidth: CGFloat = 150
  static let kHHeight: CGFloat = 50
  static let kVWidth: CGFloat = 100
  static let kVHeight: CGFloat = 50
  static let font: CGFloat = 18
}
class ReplayView: UIView {
  var orientation: ReplayOrientation = .portrait {
    didSet {
      addViews()
    }
  }
  var replayTapped: ((UIButton) -> Void)?
  private lazy var gesture: UITapGestureRecognizer = {
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleReplay))
    return tap
  }()
  lazy var image: UIImageView = {
    let image = UIImageView()
    image.contentMode = .scaleAspectFit
    image.image = UIImage(named: RBPlayerControl.Assets.replay, in: Bundle(for: CustomControlLayout.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withColor(.white)
    return image
  }()
  private lazy var replayButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: RBPlayerControl.Assets.replay, in: Bundle(for: OverlayDecorator.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    //button.imageEdgeInsets = RBPlayerControl.Metrics.playButtonEdgeInset
    button.imageView?.tintColor = .white
    button.imageView?.contentMode = .scaleAspectFit
    button.adjustsImageWhenHighlighted = false
    button.addTarget(self, action: #selector(handleReplay), for: .touchUpInside)
    return button
  }()
  lazy var label: UIButton = {
    let label = UIButton()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.setTitle(ReplayViewContansts.kReplay, for: .normal)
    label.titleLabel?.font = UIFont.systemFont(ofSize: ReplayViewContansts.font, weight: .semibold)
    label.setTitleColor(.white, for: .normal)
    label.adjustsImageWhenHighlighted = false
    label.addTarget(self, action: #selector(handleReplay), for: .touchUpInside)
    return label
  }()
  lazy var vStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.backgroundColor = .clear
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  lazy var hStack: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.backgroundColor = .clear
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  override init(frame: CGRect) {
    super.init(frame: frame)
    addViews()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  private func addTapGesture() {
    self.addGestureRecognizer(gesture)
  }
  private func addViews() {
    if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight  {
      addHStack()
      addSubviewForHStack()
    } else {
      addVStack()
      addSubviewForVStack()
    }
  }
  private func addVStack() {
    self.addSubview(vStack)
    vStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: .zero).isActive = true
    vStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: .zero).isActive = true
    vStack.topAnchor.constraint(equalTo: self.topAnchor, constant: .zero).isActive = true
    vStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: .zero).isActive = true
  }
  private func addHStack() {
    self.addSubview(hStack)
    hStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: .zero).isActive = true
    hStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: .zero).isActive = true
    hStack.topAnchor.constraint(equalTo: self.topAnchor, constant: .zero).isActive = true
    hStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: .zero).isActive = true
  }
  private func addSubviewForVStack() {
    vStack.addArrangedSubview(replayButton)
    vStack.addArrangedSubview(label)
    label.contentHorizontalAlignment = .center
  }
  private func addSubviewForHStack() {
    hStack.addArrangedSubview(label)
    label.contentHorizontalAlignment = .right
    hStack.addArrangedSubview(replayButton)
  }
  private func removeStackViews() {
    hStack.removeFromSuperview()
    vStack.removeFromSuperview()
  }
  @objc func handleReplay(_ sender: UIButton) {
    self.replayTapped?(sender)
  }
}

