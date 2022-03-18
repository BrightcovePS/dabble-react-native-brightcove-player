import Foundation
import BrightcovePlayerSDK
class PlaylistHelper {
  class func getNextVideo(with currentRefId: String,in playlist: [BCOVVideo]) -> BCOVVideo? {
    let currentIdx = playlist.firstIndex { eachVideo in
      eachVideo.properties[kBCOVVideoPropertyKeyReferenceId] as? String == currentRefId
    }
    guard let currentIndex = currentIdx,
          currentIndex + 1 <= playlist.count - 1 else {
      return nil
    }
    let nextIdx = currentIndex + 1
    return playlist[nextIdx]
  }
  class func getPreviousVideo(with currentRefId: String,in playlist: [BCOVVideo]) -> BCOVVideo? {
    let currentIdx = playlist.firstIndex { eachVideo in
      eachVideo.properties[kBCOVVideoPropertyKeyReferenceId] as? String == currentRefId
    }
    guard let currentIndex = currentIdx,
          currentIndex - 1 >= 0 else {
      return nil
    }
    let nextIdx = currentIndex - 1
    return playlist[nextIdx]
  }
  class func getVideo(with referenceId: String,in playlist: [BCOVVideo]) -> BCOVVideo? {
    let video = playlist.filter { eachVideo in
      (eachVideo.properties[kBCOVVideoPropertyKeyReferenceId] as? String) == referenceId
    }.first
    return video
  }
  class func isNextVideoAvailable(with currentRefId: String,in playlist: [BCOVVideo]) -> Bool {
    let currentIdx = playlist.firstIndex { eachVideo in
      eachVideo.properties[kBCOVVideoPropertyKeyReferenceId] as? String == currentRefId
    }
    guard let currentIndex = currentIdx,
          currentIndex + 1 <= playlist.count - 1 else {
      return false
    }
    return true
  }
  class func isPrevVideoAvailable(with currentRefId: String,in playlist: [BCOVVideo]) -> Bool {
    let currentIdx = playlist.firstIndex { eachVideo in
      eachVideo.properties[kBCOVVideoPropertyKeyReferenceId] as? String == currentRefId
    }
    guard let currentIndex = currentIdx,
          currentIndex - 1 >= 0 else {
      return false
    }
    return true
  }
}
