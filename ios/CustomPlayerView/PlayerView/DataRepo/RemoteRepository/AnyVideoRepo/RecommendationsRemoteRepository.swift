import Foundation
fileprivate struct AnyVideoRequestConstants {
   static let path = "/accounts/2779557264001/videos"
}
class RecommendationsAnyVideoRemoteRepository: RecommendationAnyVideoType {
  var successHandler: SuccessHandler?
  var errorHandler: ErrorClosure?
  let netoworkHandler = NetworkHandler<AllVideos>()
  func connectRemote() {
    netoworkHandler.successHandler = { [weak self] (response, result) in
      guard let self = self,
            let recommendations = response as? AllVideos else { return }
      self.successHandler?(recommendations)
    }
    netoworkHandler.errorHandler = { [weak self] (response, result) in
      guard let self = self else { return }
      self.errorHandler?(response)
    }
    cancelAnyExisitingRequest()
    netoworkHandler.downloadTask(with: formRequest())
  }
  func cancelAnyExisitingRequest() {
    netoworkHandler.cancelAnyExisitingRequest()
  }
  internal func formRequest() -> APIRequest {
    let apiPath = NetworkConstants.itemPath + AnyVideoRequestConstants.path
    return APIRequest(httpMethod: .get,
                      header: [
                               "Authorization": "BCOV-Policy BCpkADawqM0T70OIeC1ysPZSWqHXGas6YhSdyfXn4Y5oBh8vMEZRAVO2Yf3sS71Kd7Ev_gt66q5TY00RbA7VT9ps2pAX_GCr5q2vhxjkqDJvy-6oxL_mAYk9tOdyo6Gkfu0kcWjGPgRaq_iK"],
                      urlParameter: ParameterType.urlParameter(urlParameter: ["limit": 250]),
                      path: apiPath)
  }
  deinit {
  }
}
