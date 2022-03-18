import Foundation
struct Text_tracks : Codable {
  var id : String?
  var account_id : String?
  var src : String?
  var srclang : String?
  var label : String?
  var kind : String?
  var mime_type : String?
  var asset_id : String?
  var sources : [TextTrackSources]?
  var defaultValue : Bool?
  var width : Int?
  var height : Int?
  var bandwidth : Int?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case account_id = "account_id"
		case src = "src"
		case srclang = "srclang"
		case label = "label"
		case kind = "kind"
		case mime_type = "mime_type"
		case asset_id = "asset_id"
		case sources = "sources"
		case defaultValue = "default"
		case width = "width"
		case height = "height"
		case bandwidth = "bandwidth"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(String.self, forKey: .id)
		account_id = try values.decodeIfPresent(String.self, forKey: .account_id)
		src = try values.decodeIfPresent(String.self, forKey: .src)
		srclang = try values.decodeIfPresent(String.self, forKey: .srclang)
		label = try values.decodeIfPresent(String.self, forKey: .label)
		kind = try values.decodeIfPresent(String.self, forKey: .kind)
		mime_type = try values.decodeIfPresent(String.self, forKey: .mime_type)
		asset_id = try values.decodeIfPresent(String.self, forKey: .asset_id)
		sources = try values.decodeIfPresent([TextTrackSources].self, forKey: .sources)
		defaultValue = try values.decodeIfPresent(Bool.self, forKey: .defaultValue)
		width = try values.decodeIfPresent(Int.self, forKey: .width)
		height = try values.decodeIfPresent(Int.self, forKey: .height)
		bandwidth = try values.decodeIfPresent(Int.self, forKey: .bandwidth)
	}

}
