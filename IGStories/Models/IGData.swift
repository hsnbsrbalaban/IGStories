//
//  IGData.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import Foundation

class IGData: Codable {
    
    var data: [IGStory]
    
    init() {
        data = []
    }
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}