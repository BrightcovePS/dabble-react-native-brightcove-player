import Foundation
typealias HTTPHeaderFields = [String:String]
typealias Parameters = [String: Any]
protocol Requestable {
  var baseURL: URL { get }
  var path: String { get }
  var httpMethod: HTTPMethod { get }
  var requestTimeOut: Double { get }
  var cachePolicy: NSURLRequest.CachePolicy { get }
  var headers: HTTPHeaderFields? { get }
  var bodyParameter: ParameterType { get }
  var urlParameter: ParameterType { get }
}
