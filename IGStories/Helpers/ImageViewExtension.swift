//
//  ImageViewExtension.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 2.05.2021.
//

import UIKit

extension UIImageView {
    /**
     Loads the given url image to `image` variable.
     
     - Parameters:
        - urlString: String for the desired url.
        - completion: Completion block that will be called after the execution.
     */
    func loadImageFromUrl(urlString: String, completion: ((Bool) -> Void)?) {
        if let url = URL(string: urlString) {
            let dataTask = URLSession.shared.dataTask(with: url) { data,_,_ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.image = UIImage(data: data)
                        completion?(true)
                    }
                } else {
                    completion?(false)
                }
            }
            dataTask.resume()
        } else {
            completion?(false)
        }
    }
}
