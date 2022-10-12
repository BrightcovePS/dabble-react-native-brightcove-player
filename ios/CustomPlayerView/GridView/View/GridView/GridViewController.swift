import UIKit
class GridViewController<Cell: DynamicDataCell, DataType: GridUIModel>: UIViewController, UICollectionViewDelegateFlowLayout where Cell: UICollectionViewCell {
  var insetSafePadding: CGFloat = 5
  var selectionCallBack: ((GridUIModel?) -> Void)?
  var viewModel: GridViewModelProtocol?
  var dataSource: GridViewDataSource<Cell, DataType>?
  var delegate: GridViewDelegate?
  lazy var collectionView: UICollectionView = {
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    //layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    return collectionView
  }()
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  convenience init(viewModel: GridViewModelProtocol) {
    self.init()
    self.viewModel = viewModel
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.collectionViewLayout.invalidateLayout()
  }
  private func configureCollectionView() {
    collectionView.backgroundColor = .clear
    collectionView.isScrollEnabled = false
    self.collectionView.contentInsetAdjustmentBehavior = .never
    self.collectionView.register(Cell.self, forCellWithReuseIdentifier: String(describing:  Cell.self))
    self.collectionView.showsHorizontalScrollIndicator = false
    self.collectionView.showsVerticalScrollIndicator = false
    if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      flowLayout.scrollDirection = .horizontal
      flowLayout.itemSize = CGSize(width: OverlaySize.width, height: OverlaySize.height - insetSafePadding)
    }
    delegate = GridViewDelegate(delegate: self)
    dataSource = GridViewDataSource<Cell, DataType>(delegate: self)
    dataSource?.dataSource = viewModel?.outputModel
    self.collectionView.delegate = delegate
    self.collectionView.dataSource = dataSource
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .clear
    //collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    configureCollectionView()
    addGridView()
  }
  private func addGridView() {
    self.view.addSubview(collectionView)
    collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: .zero).isActive = true
    collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: .zero).isActive = true
    collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: .zero).isActive = true
//    collectionView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
  }
//  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//    return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//  }
}
extension GridViewController: GridDelegate {
  func didSelectionOfItem(_ indexPath: IndexPath) {
    selectionCallBack?(self.dataSource?.dataSource?[indexPath.row])
  }
}
extension GridViewController: GridDataSource {
}
