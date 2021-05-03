//
//  SnapPreviewCell.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 2.05.2021.
//

import UIKit
import AVKit

enum MovementDirection {
    case forward
    case backward
}

protocol SnapPreviewCellDelegate: class {
    func move(_ direction: MovementDirection, _ index: Int)
}

class SnapPreviewCell: UICollectionViewCell {
    //MARK: - Variables
    var snapIndex: Int = -1
    private var snap: IGSnap?
    
    private var imageView: UIImageView?
    private var videoPlayer: AVPlayer?
    private var videoLayer: AVPlayerLayer?
    
    weak var delegate: SnapPreviewCellDelegate?
    
    //MARK: - Initializer & Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.backgroundColor = .black
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        addGestureRecognizer(tapGR)
        addGestureRecognizer(longPressGR)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("Inside prepare for reuse")
        imageView?.image = nil
        imageView?.removeFromSuperview()
        imageView = nil
        
        videoPlayer?.pause()
        videoLayer?.player = nil
        videoLayer?.removeFromSuperlayer()
        videoPlayer = nil
        videoLayer = nil
    }
    
    //MARK: - Functions
    func configure(storyIndex: Int) {
        prepareForReuse()
        let snap = StoryManager.shared.getSnap(for: storyIndex, snapIndex: snapIndex)
        
        self.snap = snap
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
        imageView = UIImageView(frame: .zero)
        
        guard let iv = imageView else { return }
        iv.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView!)
        
        NSLayoutConstraint.activate([
            iv.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            iv.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            iv.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            iv.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        iv.loadImageFromUrl(urlString: urlString)
    }
    
    private func showVideo(urlString: String) {
        videoPlayer = AVPlayer()
        
        guard let vp = videoPlayer else { return }
        videoLayer = AVPlayerLayer(player: vp)
        videoLayer?.frame = contentView.bounds
        videoLayer?.videoGravity = .resizeAspect
        
        guard let vl = videoLayer else { return }
        contentView.layer.addSublayer(vl)
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        if let filePath = Bundle.main.path(forResource: "test", ofType: "mov") {
            let url = URL(fileURLWithPath: filePath)
            let avItem = AVPlayerItem(url: url)
            vp.replaceCurrentItem(with: avItem)
            vp.play()
        }
    }
    
    @objc func videoDidEnd() {
        print("video ended")
    }
    
    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        if location.x > bounds.width / 2 {
            delegate?.move(.forward, snapIndex)
        } else {
            delegate?.move(.backward, snapIndex)
        }
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began || gesture.state == .ended {
            if gesture.state == .began {
                print("began")
            } else {
                print("end")
            }
        }
    }
}
