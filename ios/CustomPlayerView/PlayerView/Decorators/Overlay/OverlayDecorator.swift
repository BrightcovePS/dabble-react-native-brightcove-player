import UIKit
import BrightcovePlayerSDK
fileprivate struct OverlayConstants {
  static let closeButtonTrailing: CGFloat = 10
  static let closeButtonTop: CGFloat = -20
  static let containerYOffset: CGFloat = 10
  static let showOverlayAnimationDuration: Double = 0.25
  static let hideOverlayAnimationDuration: Double = 0.15
}
class OverlayDecorator: NSObject, ViewDecoratorType {
  var isConnectionWindowActive: Bool = false {
    didSet {
      if !isConnectionWindowActive {
        self.nextAnyVideo = nil
      }
    }
  }
  var nextAnyVideo: BCOVVideo?
  var screenMode: BCOVPUIScreenMode? = .normal {
    didSet {
      resetConstraintsOnScreenModeChange()
    }
  }
  private lazy var closeButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(UIImage(named: Assets.close)?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.imageEdgeInsets = RBPlayerControl.Metrics.playButtonEdgeInset
    button.imageView?.tintColor = .white
    button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    button.isHidden = true
    return button
  }()
  lazy var viewModel: GridViewModel = {
    return GridViewModel(decorator: self)
  }()
  lazy var gridView: GridViewController<RecommendationsCell,  RecommendationsModel> = {
    let view = GridViewController<RecommendationsCell, RecommendationsModel>(viewModel: self.viewModel)
    view.view.translatesAutoresizingMaskIntoConstraints  = false
    return view
  }()
  // TODO: - To remove this if not used
  var isPreviewWindowActive: Bool = false
  var showOverlay: Bool = false {
    didSet {
      if showOverlay {
        self.addRecommendationsGridView()
      } else {
        removeOverlay()
      }
    }
  }
  lazy var gridContainer: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isUserInteractionEnabled = true
    view.clipsToBounds = true
    return view
  }()
  lazy private var overlayBackground: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isUserInteractionEnabled = true
    view.clipsToBounds = true
    return view
  }()
  weak var parentView: BCOVPUIPlayerView?
  required init(_ view: BCOVPUIPlayerView) {
    parentView = view
    super.init()
    NotificationCenter.default.addObserver(self, selector: #selector(resetConstraintsAndAddSubviews), name: UIDevice.orientationDidChangeNotification, object: nil)
    setOverlaySize()
  }
  private func addOverlayBg() {
    guard let view = parentView?.overlayView else {
      return
    }
    view.addSubview(overlayBackground)
    overlayBackground.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    overlayBackground.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    overlayBackground.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    overlayBackground.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
  }
  private func addContainer() {
    let view = overlayBackground
    view.addSubview(gridContainer)
    NSLayoutConstraint.activate([
      gridContainer.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      gridContainer.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: OverlayConstants.containerYOffset),
     // gridContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: RecommendationOverlayConstants.kRecommendationOverlayBottom),
      /*Donot delete - needed incase of swiping up like you tube for swipe gesture,*/
      //gridContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 80),
      gridContainer.heightAnchor.constraint(equalToConstant: OverlaySize.height),
      gridContainer.widthAnchor.constraint(equalToConstant: OverlaySize.width)
    ])
    parentView?.layoutIfNeeded()
  }
  private func addGesture() {
    let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
    gridContainer.addGestureRecognizer(gesture)
    gridContainer.isUserInteractionEnabled = true
    gesture.delegate = self
  }
  private func addGridView() {
    guard viewModel.outputModel?.count ?? 0 > 0 else {
      return
    }
    gridView.view.alpha = 1
    gridView.collectionView.collectionViewLayout.invalidateLayout()
    self.gridContainer.addSubview(gridView.view)
    gridView.view.leadingAnchor.constraint(equalTo: self.gridContainer.leadingAnchor, constant: .zero).isActive = true
    gridView.view.trailingAnchor.constraint(equalTo: self.gridContainer.trailingAnchor, constant: .zero).isActive = true
    gridView.view.topAnchor.constraint(equalTo: self.gridContainer.topAnchor, constant: .zero).isActive = true
    gridView.view.bottomAnchor.constraint(equalTo: self.gridContainer.bottomAnchor, constant: .zero).isActive = true
    gridView.dataSource?.dataSource = self.viewModel.outputModel
    gridView.collectionView.reloadData()
    //TODO: - Need to implement based on VD
    UIView.animate(withDuration: OverlayConstants.showOverlayAnimationDuration) {
      self.gridView.view.alpha = 1
    }
    parentView?.layoutIfNeeded()
  }
  @objc func addRecommendationsGridView(scrollFront: Bool = false) {
    if showOverlay {
      removeAllSubviews()
      unHideOverylay()
      addOverlayBg()
      addContainer()
      addGridView()
      performOverlayAuxillaryActions()
      //addCloseButton()
      /*To be added when gesture swipe up is enabled*/
      //addGesture()
    }
  }
  private func removeOverlay() {
    CountDownTimer.shared.stopTimer()
    cancelAnyExisitingRequest()
    removeAllSubviews()
    self.closeButton.isHidden = true
    unHideOverylay()
    performHideOverlayAuxillaryActions()
  }
  fileprivate func removeAllSubviews() {
    gridView.view.removeFromSuperview()
    gridContainer.removeFromSuperview()
    overlayBackground.removeFromSuperview()
  }
  fileprivate func setOverlaySize() {
    guard UIDevice.current.orientation.rawValue != 2,
          let referenceView =  self.parentView?.overlayView,
          let screenMode = screenMode else {
      return
    }
    OverlaySizeFactory.setupDimensions(referenceView: referenceView, screenMode: screenMode)
  }
  @objc func resetConstraintsAndAddSubviews() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      if !self.overlayBackground.isHidden {
      NSLayoutConstraint.deactivate(self.gridContainer.constraints)
      self.setOverlaySize()
      self.addRecommendationsGridView()
      self.gridView.collectionView.collectionViewLayout.invalidateLayout()
      }
    }
  }
  @objc func resetConstraintsOnScreenModeChange() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      if !self.overlayBackground.isHidden {
      NSLayoutConstraint.deactivate(self.gridContainer.constraints)
      self.setOverlaySize()
      self.addRecommendationsGridView()
      self.gridView.collectionView.collectionViewLayout.invalidateLayout()
      }
    }
  }
  func connectToRemote() {
    self.viewModel.connectRemote()
  }
  func cancelAnyExisitingRequest() {
    viewModel.cancelAnyExisitingRequest()
  }
  private func addCloseButton() {
    guard let view = parentView?.overlayView else {
      return
    }
    closeButton.isHidden = false
    view.addSubview(closeButton)
    closeButton.leadingAnchor.constraint(equalTo: gridContainer.trailingAnchor, constant: OverlayConstants.closeButtonTrailing).isActive = true
    closeButton.topAnchor.constraint(equalTo: gridContainer.topAnchor, constant: OverlayConstants.closeButtonTop).isActive = true
    closeButton.widthAnchor.constraint(equalToConstant: RecommendationOverlayConstants.kRecommendationClosebuttonWidth).isActive = true
    closeButton.heightAnchor.constraint(equalToConstant: RecommendationOverlayConstants.kRecommendationClosebuttonWidth).isActive = true
  }
  @objc private func closeTapped() {
    removeOverlay()
  }
  func hideOverylay() {
    UIView.animate(withDuration: OverlayConstants.hideOverlayAnimationDuration) {
      self.gridView.view.alpha = 0
    } completion: { _ in
      self.overlayBackground.isHidden = true
    }
  }
  func unHideOverylay() {
    self.overlayBackground.isHidden = false
  }
  func performOverlayAuxillaryActions() {
    parentView?.controlsView.isHidden = true
    parentView?.controlsFadingView.isHidden = true
  }
  func performHideOverlayAuxillaryActions() {
    parentView?.controlsView.isHidden = false
    parentView?.controlsFadingView.isHidden = false
  }
}
