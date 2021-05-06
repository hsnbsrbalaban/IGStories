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
    /**
     Fetches the story data from the data file (igdata.json).
     Decodes the fetched data to `igData` format.
     Called in `AppDelegate`, at the launch of the application.
     */
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
    
    /**
     Getter for stories array.
     
     - Returns: An array of `IGStory`
     */
    func getStories() -> [IGStory] {
        return igData.data
    }
    
    /**
     Getter for a specific story.
     
     - Parameter storyIndex: The index of the story.
     - Returns: An `IGStory` object.
     */
    func getStory(for storyIndex: Int) -> IGStory {
        return igData.data[storyIndex]
    }
    
    /**
     Getter for a specific snap of a specific story.
     
     - Parameters:
        - storyIndex: The index of the story.
        - snapIndex: The index of the snap.
     - Returns: An `IGSnap` object
     */
    func getSnap(for storyIndex: Int, snapIndex: Int) -> IGSnap {
        return igData.data[storyIndex].snaps[snapIndex]
    }
    
    /**
     Updates the `lastSeenSnapIndex` variable for a given story.
     Changes the `lastSeenSnapIndex` variable to zero if the given snap index is the last index for that story.
     
     - Parameters:
        - storyIndex: The index of the story.
        - snapIndex: The index of the snap.
     */
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
