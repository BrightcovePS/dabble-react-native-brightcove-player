import Foundation
import BrightcovePlayerSDK
class GridViewModel: GridViewModelProtocol {
  var remoteRepo: RecommendationAnyVideoType!
  var requesInProgress: Bool = false
  var videoObj: [BCOVVideo]? {
    didSet {
      self.formOutputModel()
    }
  }
  weak var decorator: ViewDecoratorType?
  var outputModel: [GridUIModel]?
  init(decorator: ViewDecoratorType) {
    self.decorator = decorator
    remoteRepo = RecommendationsAnyVideoRemoteRepository()
    formOutputModel()
  }
  func connectRemote() {
    remoteRepo.successHandler = { [weak self] response in
      guard let self = self,
            let response = response else { return }
      self.requesInProgress = false
      self.getAnyVideoFromAccount(responseObj: response)
    }
    remoteRepo.errorHandler = { response in
      // TODO: To Handle error. Need to check requirement and Visual design
      self.requesInProgress = false
      print(response as Any)
    }
    if !requesInProgress {
    requesInProgress = true
    remoteRepo.connectRemote()
    }
  }
  func formOutputModel() {
    guard let nextVideo = videoObj?.first else {
      return
    }
    let title = nextVideo.properties[kBCOVVideoPropertyKeyName] as? String
    let description = nextVideo.properties[kBCOVVideoPropertyKeyDescription] as? String
    let accountId = nextVideo.properties[kBCOVVideoPropertyKeyAccountId] as? String
    let videoId = nextVideo.properties[kBCOVVideoPropertyKeyId] as? String
    let referenceId = nextVideo.properties[kBCOVVideoPropertyKeyReferenceId] as? String
    let url = nextVideo.properties[kBCOVVideoPropertyKeyPoster] as? String
    let recommendations = RecommendationsModel(thumbnailURL: url, url: url, title: description, headingTitle: title, referenceId: referenceId, videoId: videoId, accountId: accountId)
    outputModel = [recommendations]
  }
  func getAnyVideoFromAccount(responseObj: AllVideos?) {
    let allVideos = responseObj?.videos
    let randomVideo = allVideos?.randomElement()
    let recommendations = RecommendationsModel(thumbnailURL: randomVideo?.poster, url: randomVideo?.poster, title: randomVideo?.name, headingTitle: randomVideo?.name, referenceId: randomVideo?.reference_id, videoId: randomVideo?.id, accountId: randomVideo?.account_id)
    outputModel = [recommendations]
    decorator?.showOverlay = true
    decorator?.fetchAnyBCVideo(for: randomVideo?.dictionary)
  }
  func cancelAnyExisitingRequest() {
    remoteRepo.cancelAnyExisitingRequest()
  }
}
