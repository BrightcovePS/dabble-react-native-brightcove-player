import Foundation
struct CurrentPlayerItem {
  static var shared = CurrentPlayerItem()
  var videoId: String = StringConstants.kEmptyString
  var referenceId: String = StringConstants.kEmptyString
  var playlistId: String = StringConstants.kEmptyString
  var playlistRefId: String = StringConstants.kEmptyString
  var allVideosInAccount = [Videos]()
  var playlistVideoIds = [String]()
  private init () {}
}
