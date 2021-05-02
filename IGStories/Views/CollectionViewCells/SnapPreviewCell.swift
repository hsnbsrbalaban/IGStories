//
//  SnapPreviewCell.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 2.05.2021.
//

import UIKit
import AVKit

class SnapPreviewCell: UICollectionViewCell {
    
    private lazy var imageView = UIImageView(frame: .zero)
    private lazy var videoPlayer = AVPlayer()
    
    func configure(with snap: IGSnap) {
        print(snap.mediaType)
        switch snap.type {
        case .image:
            showImage(urlString: snap.mediaUrl)
        case .video:
            showVideo(urlString: snap.mediaUrl)
        case .unknown:
            fatalError("Unknown media type!")
        }
    }
    
    private func showImage(urlString: String) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        StoryManager.shared.loadImageFromUrl(to: imageView, urlString: urlString)
    }
    
    private func showVideo(urlString: String) {
        let avLayer = AVPlayerLayer(player: videoPlayer)
        avLayer.frame = contentView.bounds
        avLayer.videoGravity = .resizeAspect
        contentView.layer.addSublayer(avLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        
        if let filePath = Bundle.main.path(forResource: "test", ofType: "mov") {
            let url = URL(fileURLWithPath: filePath)
            print("got the url")
            let avItem = AVPlayerItem(url: url)
            videoPlayer.replaceCurrentItem(with: avItem)
            videoPlayer.play()
        }
    }
    
    @objc func videoDidEnd() {
        print("video ended")
    }
    
}
