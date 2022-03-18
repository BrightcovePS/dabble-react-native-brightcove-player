import Foundation
struct Cue_points : Codable {
  var id : String?
  var name : String?
  var type : String?
  var time : Int?
  var metadata : String?
  var force_stop : Bool?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case name = "name"
		case type = "type"
		case time = "time"
		case metadata = "metadata"
		case force_stop = "force_stop"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		type = try values.decodeIfPresent(String.self, forKey: .type)
		//time = try values.decodeIfPresent(Int.self, forKey: .time)
		metadata = try values.decodeIfPresent(String.self, forKey: .metadata)
		force_stop = try values.decodeIfPresent(Bool.self, forKey: .force_stop)
	}

}
