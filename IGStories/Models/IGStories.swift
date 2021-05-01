//
//  IGStories.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import Foundation

class IGStories: Codable {
    
    var user: IGUser
    var storyCount: Int
    var stories: [IGStory]
    
    enum CodingKeys: String, CodingKey {
        case user
        case storyCount = "story_count"
        case stories
    }
    
}
