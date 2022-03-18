import Foundation
enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
}
enum ParameterType {
  case urlParameter(urlParameter: Parameters?)
  case bodyParameter(bodyParameter: Parameters?)
  func buildParamter(for urlRequest:inout URLRequest) {
    switch self {
    case .urlParameter(let paramters):
      urlParameter(for: &urlRequest, with: paramters)
    case .bodyParameter(let paramters):
      bodyParameter(for: &urlRequest, with: paramters)
    }
  }
  func urlParameter(for urlRequest:inout URLRequest, with parameters: Parameters?){
    guard
      let requestURL = urlRequest.url,
      let parameter = parameters else {
        return
    }
    if var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false), !parameter.isEmpty{
      urlComponents.queryItems = [URLQueryItem]()
      for (key, value) in parameter{
        let queryItem = URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
        urlComponents.queryItems?.append(queryItem)
      }
      urlRequest.url = urlComponents.url
    }
  }
  func bodyParameter(for urlRequest:inout URLRequest, with parameters: Parameters?){
    guard
      let parameter = parameters else {
        return
    }
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
      urlRequest.httpBody = jsonData
    } catch let error {
      print(error.localizedDescription)
    }
  }
}
