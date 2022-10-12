import Foundation
struct RecommendationsModel: GridUIModel, Codable {
  var identifier: String? = String(describing: Self.self)
  var thumbnailURL: String?
  var url: String?
  var title: String?
  var headingTitle: String?
  var referenceId: String?
  var videoId: String?
  var playlistReferenceId: String?
  var playlistId: String?
  var accountId: String?
  var policyKey: String?
}
