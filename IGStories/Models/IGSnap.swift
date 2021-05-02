//
//  IGStory.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import Foundation

enum IGSnapType: String {
    case image
    case video
    case unknown
}

class IGSnap: Codable {
    
    var mediaType: String
    var mediaUrl: String
    
    var type: IGSnapType {
        switch mediaType {
        case IGSnapType.image.rawValue:
            return IGSnapType.image
        case IGSnapType.video.rawValue:
            return IGSnapType.video
        default:
            return IGSnapType.unknown
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaUrl = "media_url"
    }
    
}
