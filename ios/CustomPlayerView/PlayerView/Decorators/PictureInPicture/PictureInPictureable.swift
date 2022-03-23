import Foundation
typealias PictureInPictureDecoratorType = PlayerDecoratorProtocol & PictureInPictureable
/*LSP - Abstract interface shared by decorator and Playerview (core object)*/
protocol PictureInPictureable: AnyObject {
  func checkIfPictureInPictureEnabled()
  func addPictureInPictureObserver()
  func startPictureInPicture()
  func hideControls()
  func showControls()
}
