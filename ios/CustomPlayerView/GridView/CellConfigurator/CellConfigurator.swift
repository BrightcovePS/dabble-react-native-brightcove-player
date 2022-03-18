import UIKit
import Foundation
class CellConfigurator<CellType: DynamicDataCell, DataType: GridUIModel> where CellType: UICollectionViewCell  {
  // MARK: Property Declrations
  var item: GridUIModel?
  var cell: CellType?
  // MARK: Methods
  init(item: GridUIModel, cell: CellType) {
    self.item = item
    self.cell = cell
    configure()
  }
  func configure() {
    cell?.configure(item as? CellType.DataType)
  }
}
