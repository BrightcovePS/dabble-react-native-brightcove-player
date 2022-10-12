import Foundation
protocol RemoteRepository {
  func connectRemote()
  func cancelAnyExisitingRequest()
  func formRequest() -> APIRequest
}
