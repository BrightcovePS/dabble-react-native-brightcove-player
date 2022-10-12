import Foundation
enum APIError: Error {
  case apiError(message: Response)
}
extension APIError: Codable {
  enum CodingKeys: String, CodingKey {
    case apiError
  }
  enum APIErrorCodingError: Error {
    case decoding(String)
  }
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let value = try? values.decode(Response.self, forKey: .apiError) {
      self = .apiError(message: value)
      return
    }
    throw APIErrorCodingError.decoding("Decoding failed")
  }
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    switch self {
    case .apiError(let message):
      try container.encode(message, forKey: .apiError)
    }
  }
}
