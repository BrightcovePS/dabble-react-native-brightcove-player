import Foundation
struct MEDCError: Codable {
  var error: APIError?
}
struct Response: Codable {
  let message: String?
  let code: Int?
}
enum Result {
  case success
  case failure
}
class SessionConfigurator: NSObject {
  static var configuration: URLSessionConfiguration {
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.isDiscretionary = false
    sessionConfig.allowsCellularAccess = true
    sessionConfig.shouldUseExtendedBackgroundIdleMode = true
    return sessionConfig
  }
  static var session: URLSession?
}
class NetworkHandler<T>:NSObject,URLSessionDelegate,URLSessionDataDelegate, URLSessionDownloadDelegate where T: Codable {
  typealias SuccessHandler = ((Codable?, Result) ->Void)
  typealias ErrorClosure = ((Codable?, Result) ->Void)
  var successHandler: SuccessHandler?
  var errorHandler: ErrorClosure?
  typealias ResponseObjectType = T
  var identifier: String?
  override init() {
    super.init()
  }
  var urlSession: URLSession? {
    return URLSession(configuration: SessionConfigurator.configuration, delegate:self, delegateQueue: OperationQueue.current)
  }
  func dataTask(with request:Requestable){
    urlSession?.dataTask(with:  createRequest(with: request)).resume()
  }
  func downloadTask(with request:Requestable){
    urlSession?.downloadTask(with: self.createRequest(with: request)).resume()
   
  }
  func cancelAnyExisitingRequest() {
    urlSession?.invalidateAndCancel()
  }
  func createRequest(with request:Requestable) -> URLRequest{
    var urlRequest = URLRequest(url: (request.baseURL.appendingPathComponent(request.path)),
                                cachePolicy: request.cachePolicy,
                                timeoutInterval: request.requestTimeOut)
    request.urlParameter.buildParamter(for: &urlRequest)
    request.bodyParameter.buildParamter(for: &urlRequest)
    urlRequest.httpMethod = request.httpMethod.rawValue
    createRequestHeader(for: &urlRequest, with: request.headers)
    return urlRequest
  }
  private func createRequestHeader(for urlRequest:inout URLRequest, with headerFields: HTTPHeaderFields?){
    guard let header = headerFields else {
      return
    }
    for (key, value) in header{
      urlRequest.setValue(value, forHTTPHeaderField: key)
    }
  }
  private func handleNetworkResponse(_ response: URLResponse?) throws {
    if let httpResponse = response as? HTTPURLResponse {
      switch httpResponse.statusCode {
      case 200...299:
       break
      case 400...500:
        throw APIError.apiError(message: Response(message: NetworkConstants.error, code: httpResponse.statusCode))
      default:
        throw APIError.apiError(message: Response(message: NetworkConstants.error, code: nil))
      }
    }
  }
   func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if error != nil {
      errorHandler?(APIError.apiError(message: Response(message: error?.localizedDescription, code: nil)), .failure)
    }
  }
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    guard let stringCopy = try? String(contentsOf: location),
          let jsonData = stringCopy.data(using: .utf8) else { return }
    let decoder = JSONDecoder()
    do {
      try handleNetworkResponse(downloadTask.response)
      let responseObject = try decoder.decode(ResponseObjectType.self, from: jsonData)
      successHandler?(responseObject, .success)
    } catch APIError.apiError(let message) {
      print(message)
      errorHandler?(MEDCError(error: APIError.apiError(message: message)), .failure)
    } catch  let error {
      print(error)
      errorHandler?(MEDCError(error: APIError.apiError(message: Response(message: NetworkConstants.failure, code: nil))), .failure)
    }
  }
}
