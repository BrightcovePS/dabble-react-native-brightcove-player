import Foundation
extension OverlayDecorator: AnyVideoProtocol {
  func fetchAnyBCVideo(for allVideos: [Videos]?) {
    var randomVideo: Videos?
    repeat {
      randomVideo = getRandomVideo(allVideos: allVideos)
    } while (randomVideo?.id == CurrentPlayerItem.shared.videoId)
    let recommendations = RecommendationsModel(thumbnailURL: randomVideo?.poster, url: randomVideo?.poster, title: randomVideo?.name, headingTitle: randomVideo?.name, referenceId: randomVideo?.reference_id, videoId: randomVideo?.id, accountId: randomVideo?.account_id)
    viewModel.outputModel = [recommendations]
    //self.showOverlay = true  Commented for 10 sec buffer
    self.fetchBCVideo(for: randomVideo?.dictionary)
  }
  func fetchBCVideo(for json: [AnyHashable : Any]?) {
    guard let parentView = parentView as? PlayerView,
          let json = json else {
      return
    }
    parentView.fetchAnyBCVideo(for: json)
  }
  private func getRandomVideo(allVideos: [Videos]?) -> Videos? {
    return allVideos?.randomElement()
  }
}
