import Foundation
struct Thumbnail_sources : Codable {
  var src : String?

	enum CodingKeys: String, CodingKey {

		case src = "src"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		src = try values.decodeIfPresent(String.self, forKey: .src)
	}

}
