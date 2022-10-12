import Foundation
extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
struct AllVideos : Codable {
	var count : Int?
  var videos : [Videos]?

	enum CodingKeys: String, CodingKey {

		case count = "count"
		case videos = "videos"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		count = try values.decodeIfPresent(Int.self, forKey: .count)
		videos = try values.decodeIfPresent([Videos].self, forKey: .videos)
	}

}
