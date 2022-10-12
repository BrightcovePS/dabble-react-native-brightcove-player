import Foundation
struct Videos : Codable {
  var poster : String?
  var thumbnail : String?
  var poster_sources : [Poster_sources]?
  var thumbnail_sources : [Thumbnail_sources]?
  var description : String?
  var tags : [String]?
  var cue_points : [Cue_points]?
  var custom_fields : Custom_fields?
  var account_id : String?
  var sources : [Sources]?
  var name : String?
  var reference_id : String?
  var long_description : String?
  var duration : Int?
  var economics : String?
  var text_tracks : [Text_tracks]?
  var published_at : String?
  var created_at : String?
  var updated_at : String?
  var offline_enabled : Bool?
  var link : String?
  var id : String?
  var ad_keys : String?
  
  enum CodingKeys: String, CodingKey {
    
    case poster = "poster"
    case thumbnail = "thumbnail"
    case poster_sources = "poster_sources"
    case thumbnail_sources = "thumbnail_sources"
    case description = "description"
    case tags = "tags"
    case cue_points = "cue_points"
    case custom_fields = "custom_fields"
    case account_id = "account_id"
    case sources = "sources"
    case name = "name"
    case reference_id = "reference_id"
    case long_description = "long_description"
    case duration = "duration"
    case economics = "economics"
    case text_tracks = "text_tracks"
    case published_at = "published_at"
    case created_at = "created_at"
    case updated_at = "updated_at"
    case offline_enabled = "offline_enabled"
    case link = "link"
    case id = "id"
    case ad_keys = "ad_keys"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    poster = try values.decodeIfPresent(String.self, forKey: .poster)
    thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
    //poster_sources = try values.decodeIfPresent([Poster_sources].self, forKey: .poster_sources)
    //thumbnail_sources = try values.decodeIfPresent([Thumbnail_sources].self, forKey: .thumbnail_sources)
    description = try values.decodeIfPresent(String.self, forKey: .description)
    tags = try values.decodeIfPresent([String].self, forKey: .tags)
    cue_points = try values.decodeIfPresent([Cue_points].self, forKey: .cue_points)
    //custom_fields = try values.decodeIfPresent(Custom_fields.self, forKey: .custom_fields)
    account_id = try values.decodeIfPresent(String.self, forKey: .account_id)
    sources = try values.decodeIfPresent([Sources].self, forKey: .sources)
    name = try values.decodeIfPresent(String.self, forKey: .name)
    reference_id = try values.decodeIfPresent(String.self, forKey: .reference_id)
    long_description = try values.decodeIfPresent(String.self, forKey: .long_description)
    duration = try values.decodeIfPresent(Int.self, forKey: .duration)
    economics = try values.decodeIfPresent(String.self, forKey: .economics)
    text_tracks = try values.decodeIfPresent([Text_tracks].self, forKey: .text_tracks)
    published_at = try values.decodeIfPresent(String.self, forKey: .published_at)
    created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
    updated_at = try values.decodeIfPresent(String.self, forKey: .updated_at)
    offline_enabled = try values.decodeIfPresent(Bool.self, forKey: .offline_enabled)
    //link = try values.decodeIfPresent(String.self, forKey: .link)
    id = try values.decodeIfPresent(String.self, forKey: .id)
    ad_keys = try values.decodeIfPresent(String.self, forKey: .ad_keys)
  }
  
}
