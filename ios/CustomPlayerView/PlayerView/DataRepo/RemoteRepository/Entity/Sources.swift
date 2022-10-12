import Foundation
struct Sources : Codable {
  var ext_x_version : String?
  var src : String?
  var type : String?

	enum CodingKeys: String, CodingKey {

		case ext_x_version = "ext_x_version"
		case src = "src"
		case type = "type"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		ext_x_version = try values.decodeIfPresent(String.self, forKey: .ext_x_version)
		src = try values.decodeIfPresent(String.self, forKey: .src)
		type = try values.decodeIfPresent(String.self, forKey: .type)
	}

}
