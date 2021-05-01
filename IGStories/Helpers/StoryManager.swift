//
//  StoryManager.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import UIKit

class StoryManager {
    //MARK: - Instance & Initializers
    static let shared = StoryManager()
    
    init() { }
    
    //MARK: - Variables
    private var igData: IGData?
    
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
    
    func getStoriesArray() -> [IGStory] {
        return igData?.data ?? []
    }
    
    func loadImageFromUrl(to imageView: UIImageView, urlString: String) {
        if let url = URL(string: urlString) {
            let dataTask = URLSession.shared.dataTask(with: url) { data,_,_ in
                if let data = data {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: data)
                    }
                }
            }
            dataTask.resume()
        }
    }
    
}
