//
//  SnapPreviewCell.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 2.05.2021.
//

import UIKit

class SnapPreviewCell: UICollectionViewCell {
    
    private lazy var imageView = UIImageView(frame: .zero)
    
    func configure(with snap: IGSnap) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: contentView.bounds.height - contentView.safeAreaInsets.top - contentView.safeAreaInsets.bottom)
        ])
        
        StoryManager.shared.loadImageFromUrl(to: imageView, urlString: snap.mediaUrl)
    }
    
}
