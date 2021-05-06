//
//  IGUser.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import Foundation

/**
 User model. Contains username and profile picture url.
 */
class IGUser: Codable {
    
    var username: String
    var profilePicUrl: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case profilePicUrl = "profile_picture"
    }
    
}
