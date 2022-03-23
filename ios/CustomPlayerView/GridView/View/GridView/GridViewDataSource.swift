import UIKit
protocol GridDataSource: AnyObject {

}
class GridViewDataSource<Cell: DynamicDataCell, DataType: GridUIModel>: NSObject, UICollectionViewDataSource where Cell: UICollectionViewCell {
  var dataSource: [GridUIModel]?
  weak var delegate: GridDataSource?
  var configurator: CellConfigurator<Cell, DataType>!
  init(delegate: GridDataSource) {
    self.delegate = delegate
  }
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource?.count ?? .zero
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: Cell.self), for: indexPath) as? Cell else {
      return UICollectionViewCell()
    }
    if let configItem = dataSource?[indexPath.row] {
      configurator = CellConfigurator<Cell, DataType>(item: configItem, cell: cell)
    }
    return cell
  }
}
