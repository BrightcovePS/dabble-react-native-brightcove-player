import Foundation
struct Custom_fields : Codable {
  var customfield1: String?
  var customfield2: String?
	enum CodingKeys: String, CodingKey {
    case customfield1 = "customfield1"
    case customfield2 = "customfield2"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
    customfield1 = try values.decodeIfPresent(String.self, forKey: .customfield1)
    customfield2 = try values.decodeIfPresent(String.self, forKey: .customfield2)
	}

}
