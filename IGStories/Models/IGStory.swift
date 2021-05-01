//
//  IGStories.swift
//  IGStory
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import Foundation

class IGStory: Codable {
    
    var id: String
    var user: IGUser
    var storyCount: Int
    var stories: [IGSnap]
    var lastSeenStoryIndex: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case storyCount = "story_count"
        case stories
    }
    
}
