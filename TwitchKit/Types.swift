public struct ApiError: Error, Codable {
    public let error: String
    public let message: String
    public let status: Int
}

public struct Welcome: Codable {
    public let links: WelcomeLinks
    public let featured: [Featured]
    
    enum CodingKeys: String, CodingKey {
        case links = "_links"
        case featured
    }
}

public struct Featured: Codable {
    public let image: String
    public let priority: Int
    public let scheduled, sponsored: Bool
    public let text, title: String
    public let stream: Stream
}

public struct Stream: Codable {
    public let id: Int
    public let game: String
    public let viewers: Int
    public let videoHeight: Int?
    public let averageFPS: Double?
    public let delay: Int
    public let createdAt: String?
    public let isPlaylist: Bool?
    public let streamType: StreamType?
    public let preview: Preview
    public let channel: Channel
    public let links: StreamLinks
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case game, viewers
        case videoHeight = "video_height"
        case averageFPS = "average_fps"
        case delay
        case createdAt = "created_at"
        case isPlaylist = "is_playlist"
        case streamType = "stream_type"
        case preview, channel
        case links = "_links"
    }
}

public struct Channel: Codable {
    public let mature, partner: Bool
    public let status: String
    public let broadcasterLanguage: String?
    public let displayName: String?
    public let game: String
    public let language: String
    public let id: Int
    public let name: String
    public let createdAt: String?
    public let updatedAt: String?
    public let logo: String
    public let videoBanner: String?
    public let profileBanner: String?
    public let profileBannerBackgroundColor: String?
    public let url: String
    public let views, followers: Int
    public let links: ChannelLinks
    
    enum CodingKeys: String, CodingKey {
        case mature, partner, status
        case broadcasterLanguage = "broadcaster_language"
        case displayName = "display_name"
        case game, language
        case id = "_id"
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case logo
        case videoBanner = "video_banner"
        case profileBanner = "profile_banner"
        case profileBannerBackgroundColor = "profile_banner_background_color"
        case url, views, followers
        case links = "_links"
    }
}

public struct ChannelLinks: Codable {
    public let linksSelf, follows, commercial: String
    public let streamKey: String?
    public let chat, features, subscriptions, editors: String
    public let teams, videos: String
    
    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case follows, commercial
        case streamKey = "stream_key"
        case chat, features, subscriptions, editors, teams, videos
    }
}

public struct StreamLinks: Codable {
    public let linksSelf: String
    
    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
    }
}

public struct Preview: Codable {
    public let small, medium, large, template: String
}

public enum StreamType: String, Codable {
    case live = "live"
}

public struct WelcomeLinks: Codable {
    public let linksSelf, next: String
    
    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case next
    }
}

public struct StreamAccessToken: Codable {
    public let token: String
    public let sig: String
    public let mobileRestricted: Bool
}
