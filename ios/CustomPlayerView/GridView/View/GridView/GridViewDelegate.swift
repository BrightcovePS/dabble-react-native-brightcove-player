import UIKit
protocol GridDelegate: AnyObject {
  func didSelectionOfItem(_ indexPath: IndexPath)
}
class GridViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  weak var delegate: GridDelegate?
  init(delegate: GridDelegate) {
    self.delegate = delegate
  }
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    self.delegate?.didSelectionOfItem(indexPath)
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: OverlaySize.width, height: OverlaySize.height)
  }
}
