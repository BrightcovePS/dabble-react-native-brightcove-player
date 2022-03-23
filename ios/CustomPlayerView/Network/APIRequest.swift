import Foundation
class APIRequest: Requestable {
  var baseURL: URL {
    guard let url = URL(string: NetworkConstants.baseUrl) else {
      fatalError("Could not convert url")
    }
    return url
  }
  var path: String
  var httpMethod: HTTPMethod
  var requestTimeOut: Double
  var cachePolicy: NSURLRequest.CachePolicy
  var headers: HTTPHeaderFields?
  var bodyParameter: ParameterType
  var urlParameter: ParameterType
  
  init(httpMethod: HTTPMethod = .get,
       requestTimeOut: Double = NetworkConstants.defaultTimeOut,
       header: HTTPHeaderFields? = nil,
       cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData, bodyParameter: ParameterType = .bodyParameter(bodyParameter: nil),
       urlParameter: ParameterType = .urlParameter(urlParameter: nil),
       path: String) {
    self.headers = header
    self.httpMethod = httpMethod
    self.path = path
    self.requestTimeOut = requestTimeOut
    self.bodyParameter = bodyParameter
    self.urlParameter = urlParameter
    self.cachePolicy = cachePolicy
  }
}
