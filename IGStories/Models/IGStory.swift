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
    var snapCount: Int
    var snaps: [IGSnap]
    var lastSeenSnapIndex: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case user
        case snapCount = "snap_count"
        case snaps
    }
    
}
