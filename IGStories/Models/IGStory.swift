//
//  IGStory.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import Foundation

enum IGStoryType: String {
    case image
    case video
    case unknown
}

class IGStory: Codable {
    
    var mediaType: String
    var mediaUrl: String
    var lastUpdated: String
    
    var type: IGStoryType {
        switch mediaType {
        case IGStoryType.image.rawValue:
            return IGStoryType.image
        case IGStoryType.video.rawValue:
            return IGStoryType.video
        default:
            return IGStoryType.unknown
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaUrl = "media_url"
        case lastUpdated = "last_updated"
    }
    
}
