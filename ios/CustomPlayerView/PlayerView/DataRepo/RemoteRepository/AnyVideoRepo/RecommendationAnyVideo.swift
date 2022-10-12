import Foundation
typealias RecommendationAnyVideoType = RemoteRepository & RecommendationAnyVideo
protocol RecommendationAnyVideo {
  typealias SuccessHandler = ((AllVideos?) ->Void)
  typealias ErrorClosure = ((Codable?) ->Void)
  var successHandler: SuccessHandler? { get set }
  var errorHandler: ErrorClosure? { get set }
}
