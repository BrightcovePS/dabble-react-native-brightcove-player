import Foundation
struct TextTrackSources : Codable {
  var src : String?

	enum CodingKeys: String, CodingKey {

		case src = "src"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		src = try values.decodeIfPresent(String.self, forKey: .src)
	}

}
