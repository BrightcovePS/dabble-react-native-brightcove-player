import UIKit
struct TimerConstants {
  static let nextVideoThumbnailDuration: Double = 10
  static let thumbnailVideoEndOffset: Double = 10
  static let apiCallVideoEndOffset: Double = 20
}
fileprivate struct RecommendationsCellConstants {
  static let playButtonWidth: CGFloat = 60
  static let playButtonHeight: CGFloat = 60
}
class RecommendationsCell: UICollectionViewCell, DynamicDataCell {
  let thumbnailHeightMultiplier: CGFloat = 0.785
  let titleHeight: CGFloat = 36
  let closeButtonEdgeInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
  var circularProgressBarView: PBCircularProgressView!
  private var timerView: TimerView!
  var buttonPressedAction: ((RecommendationsModel?) -> Void)?
  var model: RecommendationsModel?
  typealias DataType = RecommendationsModel
  private lazy var closeButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: Assets.close, in: Bundle(for: RecommendationsCell.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.imageEdgeInsets = closeButtonEdgeInset
    button.imageView?.tintColor = .white
    button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    return button
  }()
  private lazy var thumbnail: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.isUserInteractionEnabled = true
    imageView.layer.borderWidth = 1.5
    imageView.layer.borderColor = UIColor.white.cgColor
    return imageView
  }()
  private lazy var gesture: UITapGestureRecognizer = {
    let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    return tap
  }()
  private lazy var playImage: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.image =  UIImage(named: Assets.playImage, in: Bundle(for:RecommendationsCell.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    imageView.tintColor = .white
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  private lazy var playButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: Assets.playImage, in: Bundle(for: RecommendationsCell.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.imageEdgeInsets = RBPlayerControl.Metrics.playEdgeInset
    button.imageView?.tintColor = .white
    button.addTarget(self, action: #selector(handlePlayTapped), for: .touchUpInside)
    return button
  }()
  private lazy var headingLabel: UILabel = {
    let label = UILabel()
    label.text = "Test"
    label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
    label.textColor = .black
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    //label.sizeToFit()
    label.textAlignment = .left
    label.contentMode = .bottomLeft
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  private lazy var title: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    label.textColor = .white
    label.numberOfLines = 2
    label.lineBreakMode = .byTruncatingTail
    //label.sizeToFit()
    label.textAlignment = .center
    label.contentMode = .bottomLeft
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.backgroundColor = .clear
    stackView.distribution = .fillProportionally
   // stackView.spacing = RBPlayerControl.Metrics.smallSpacing
    return stackView
  }()
  // TODO: Based on the final design, can be converted to a simple string object
  private lazy var url: UILabel = {
    let label = UILabel()
    return label
  }()
  override init(frame: CGRect) {
    super.init(frame: .zero)
    self.contentView.backgroundColor = .clear
    resetForReuse()
    addSubviews()
  }
  override func prepareForReuse() {
    super.prepareForReuse()
    resetForReuse()
    addSubviews()
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
    print("Cell tapped")
    guard let recommendationModel =  model,
          let urlString = recommendationModel.url,
          let url = URL(string: urlString) else { return }
    //UIApplication.shared.open(url)
    timerView.timer?.invalidate()
    CountDownTimer.shared.stopTimer()
    circularProgressBarView = nil
    selectionActionDispatch()
  }
  @objc func handlePlayTapped() {
    timerView.timer?.invalidate()
    CountDownTimer.shared.stopTimer()
    circularProgressBarView = nil
    selectionActionDispatch()
  }
  func addSubviews() {
    addStackView()
    addThumbnailToStack()
    addTimerView()
    addCloseButton()
    addTitleToStack()
    addPlayButton()
    //addHeadingTitleLabel()
    //addTapgesture()
    //setUpCircularProgressBarView()
  }
  private func addStackView() {
    contentView.addSubview(stackView)
    stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .zero).isActive = true
    stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: .zero).isActive = true
    stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
  }
  func addThumbnailToStack() {
    thumbnail.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
    stackView.addArrangedSubview(thumbnail)
  }
  func addTitleToStack() {
    title.heightAnchor.constraint(greaterThanOrEqualToConstant: titleHeight).isActive = true
    stackView.addArrangedSubview(title)
  }
  func addTapgesture() {
    ///self.contentView.isUserInteractionEnabled = true
    contentView.addGestureRecognizer(gesture)
  }
  private func resetForReuse() {
    self.contentView.subviews.forEach { eachSubView in
      eachSubView.removeFromSuperview()
    }
    thumbnail.image = UIColor.darkGray.image()
    thumbnail.backgroundColor = .darkGray
  }
  private func addTimerView() {
    let nextVideoDuration = Int(TimerConstants.nextVideoThumbnailDuration)
    let totalsecond: Double = Double(timerView?.runCount ?? nextVideoDuration)
    timerView = TimerView(timerDuration: totalsecond > 0 ? totalsecond: TimerConstants.nextVideoThumbnailDuration)
    timerView.runCount = Int(totalsecond)
    contentView.addSubview(timerView)
    timerView.leadingAnchor.constraint(equalTo: thumbnail.leadingAnchor, constant: RBPlayerControl.Metrics.smallSpacing).isActive = true
    timerView.topAnchor.constraint(equalTo: thumbnail.topAnchor, constant: .zero).isActive = true
    timerView.widthAnchor.constraint(equalToConstant: 2*RecommendationOverlayConstants.kRecommendationClosebuttonWidth).isActive = true
    timerView.heightAnchor.constraint(equalToConstant: RecommendationOverlayConstants.kRecommendationClosebuttonWidth).isActive = true
    timerView.progressCompleted = { [weak self] in
      guard  let self = self else {
        return
      }
      self.selectionActionDispatch()
      self.timerView = nil
    }
  }
  private func addCloseButton() {
    thumbnail.addSubview(closeButton)
    closeButton.trailingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: .zero).isActive = true
    closeButton.topAnchor.constraint(equalTo: thumbnail.topAnchor, constant: .zero).isActive = true
    closeButton.widthAnchor.constraint(equalToConstant: RecommendationOverlayConstants.kRecommendationClosebuttonWidth).isActive = true
    closeButton.heightAnchor.constraint(equalToConstant: RecommendationOverlayConstants.kRecommendationClosebuttonWidth).isActive = true
  }
  func addThumbnailImage() {
    contentView.addSubview(thumbnail)
    NSLayoutConstraint.activate([
      thumbnail.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      thumbnail.topAnchor.constraint(equalTo: contentView.topAnchor),
      thumbnail.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1),
      thumbnail.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: thumbnailHeightMultiplier)
    ])
  }
  func addPlayImage() {
    thumbnail.addSubview(playImage)
    NSLayoutConstraint.activate([
      playImage.centerXAnchor.constraint(equalTo: thumbnail.centerXAnchor),
      playImage.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor),
      playImage.widthAnchor.constraint(equalToConstant: RecommendationOverlayConstants.kRecommendationOverlayPlayWidth),
      playImage.heightAnchor.constraint(equalToConstant: RecommendationOverlayConstants.kRecommendationOverlayPlayHeight)
    ])
  }
  func addPlayButton() {
    thumbnail.addSubview(playButton)
    NSLayoutConstraint.activate([
      playButton.centerXAnchor.constraint(equalTo: thumbnail.centerXAnchor),
      playButton.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor),
      playButton.widthAnchor.constraint(equalToConstant: RecommendationsCellConstants.playButtonWidth),
      playButton.heightAnchor.constraint(equalToConstant: RecommendationsCellConstants.playButtonHeight)
    ])
  }
  func addTitleLabel() {
    contentView.addSubview(title)
    title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .zero).isActive = true
    title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: .zero).isActive = true
    title.topAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: 1.5).isActive = true
    title.heightAnchor.constraint(lessThanOrEqualToConstant: titleHeight).isActive = true
  }
  func addHeadingTitleLabel() {
    contentView.addSubview(headingLabel)
    NSLayoutConstraint.activate([
      headingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: RecommendationOverlayConstants.kRecommendationOverlayURLLeading),
      headingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: .zero),
      headingLabel.bottomAnchor.constraint(equalTo: title.topAnchor, constant: .zero),
      headingLabel.heightAnchor.constraint(lessThanOrEqualToConstant: RecommendationOverlayConstants.kRecommendationOverlayURLHeight)
    ])
  }
  func configure(_ dataType: RecommendationsModel?) {
    if let imageUrl = dataType?.thumbnailURL {
      self.thumbnail.setImage(url: imageUrl,
                              placeholderImage: UIColor.darkGray.image(),
                              completion: nil)
    }
    self.model = dataType
    title.text = dataType?.title
    url.text = dataType?.url
    headingLabel.text = dataType?.headingTitle
  }
  func setUpCircularProgressBarView() {
    // set view
    circularProgressBarView = PBCircularProgressView(arcRadius: 20,
                                                     lineWidth: 2,
                                                     circleStrokeColor: .lightGray,
                                                     progressStrokeColor: .red,
                                                     progressAnimationDuration: TimerConstants.nextVideoThumbnailDuration)
    circularProgressBarView.pauseDownloadButtonAction = { pauseStatus, progressStatus in
      print(pauseStatus, progressStatus)
    }
    circularProgressBarView.progressCompleted = { [weak self] in
      guard  let self = self,
             self.circularProgressBarView != nil else {
        return
      }
      self.selectionActionDispatch()
    }
    circularProgressBarView.pauseDownloadButtonSize = CGSize(width: 35, height: 35)
    contentView.addSubview(circularProgressBarView)
    circularProgressBarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    circularProgressBarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    circularProgressBarView.widthAnchor.constraint(equalToConstant: RBPlayerControl.Metrics.smallWidth).isActive = true
    circularProgressBarView.heightAnchor.constraint(equalToConstant: RBPlayerControl.Metrics.smallWidth).isActive = true
    self.circularProgressBarView.progress = 1
  }
  @objc private func closeTapped() {
    self.circularProgressBarView = nil
    timerView.timer?.invalidate()
    CountDownTimer.shared.stopTimer()
    closeActionDispatch()
  }
  private func closeActionDispatch() {
    OverlayReducer.shared.store?.dispatch(action: OverlayAction(didSelected: false, indexPath: IndexPath(), referenceId: nil, videoId: nil, actionType: .closeOverlay))
  }
  private func selectionActionDispatch() {
    OverlayReducer.shared.store?.dispatch(action: OverlayAction(didSelected: true, indexPath: IndexPath(), referenceId: self.model?.referenceId, videoId: self.model?.videoId, actionType: .overlaySelection))
  }
  deinit {
    self.timerView?.timer?.invalidate()
    CountDownTimer.shared.stopTimer()
  }
}
