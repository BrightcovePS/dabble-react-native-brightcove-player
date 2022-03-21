import Foundation
fileprivate struct AnyVideoRequestConstants {
  static let path = "/accounts/\(AccountConfig.accountId)/videos"
  static let keyAuthorization = "Authorization"
  static let keyLimit = "limit"
  static let bcovPolicy = "BCOV-Policy"
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
                        AnyVideoRequestConstants.keyAuthorization: "\(AnyVideoRequestConstants.bcovPolicy) \(AccountConfig.policyKey)"],
                      urlParameter: ParameterType.urlParameter(urlParameter: [AnyVideoRequestConstants.keyLimit: AccountConfig.allVideosLimit]),
                      path: apiPath)
  }
  deinit {
  }
}
