//
//  StoryManager.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import UIKit

class StoryManager {
    //MARK: - Instance
    static let shared = StoryManager()
    
    //MARK: - Variables
    private var igData = IGData()
    
    //MARK: - Functions
    func fetchStories() {
        do {
            if let bundlePath = Bundle.main.path(forResource: "igdata", ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                
                igData = try JSONDecoder().decode(IGData.self, from: jsonData)
            }
        } catch {
            print("Error while reading / decoding data!")
        }
    }
    
    func getStories() -> [IGStory] {
        return igData.data
    }
    
    func getStory(for storyIndex: Int) -> IGStory {
        return igData.data[storyIndex]
    }
    
    func getSnap(for storyIndex: Int, snapIndex: Int) -> IGSnap {
        return igData.data[storyIndex].snaps[snapIndex]
    }
    
    func updateLastSeenSnapIndex(storyIndex: Int, snapIndex: Int) {
        if snapIndex == igData.data[storyIndex].snapCount {
            igData.data[storyIndex].lastSeenSnapIndex = 0
            return
        }
        
        if igData.data[storyIndex].lastSeenSnapIndex < snapIndex {
            igData.data[storyIndex].lastSeenSnapIndex = snapIndex
        }
    }
}
