//
//  HomeViewCell.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import UIKit

class HomeViewCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    var label = UILabel()
    
    func setupUI(imageUrlString: String, username: String) {
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.heightAnchor.constraint(equalToConstant: 21),
            
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: label.topAnchor)
        ])
        
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.007843137255, green: 0.2784313725, blue: 0.368627451, alpha: 1)
        label.text = username
        label.font = .systemFont(ofSize: 11)
        
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = contentView.bounds.width * 0.5
        imageView.layer.borderColor = #colorLiteral(red: 0.4078431373, green: 0.4745098039, blue: 0.5019607843, alpha: 1)
        imageView.layer.borderWidth = 2
        StoryManager.shared.loadImageFromUrl(to: imageView, urlString: imageUrlString)
    }
}
