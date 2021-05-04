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
    /// Move between snaps (tap gesture)
    func move(_ direction: MovementDirection, _ index: Int)
    /// Inform the delegate that long press gesture began
    func longPressBegan()
    /// Inform the delegate that long press gesture ended
    func longPressEnded()
}

class SnapPreviewCell: UICollectionViewCell {
    //MARK: - Constants
    static let identifier = "SnapPreviewCell"
    
    //MARK: - Variables
    private var snapIndex: Int = -1
    
    private var imageView: UIImageView? = nil
    private var videoView: VideoPlayerView? = nil
    
    private weak var delegate: SnapPreviewCellDelegate?
    
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
        
        // Add gestures
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        addGestureRecognizer(tapGR)
        addGestureRecognizer(longPressGR)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        snapIndex = -1
        
        imageView?.image = nil
        imageView?.removeFromSuperview()
        imageView = nil
        
        videoView?.removeFromSuperview()
        videoView = nil
        
        delegate = nil
    }
    
    //MARK: - Functions
    func configure(storyIndex: Int, snapIndex: Int, delegate: SnapPreviewCellDelegate) {
        self.snapIndex = snapIndex
        self.delegate = delegate
        
        let snap = StoryManager.shared.getSnap(for: storyIndex, snapIndex: snapIndex)
        
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
        imageView?.contentMode = .scaleAspectFit
        
        addViewToContentView(view: imageView)
        
        imageView?.loadImageFromUrl(urlString: urlString)
    }
    
    private func showVideo(urlString: String) {
        videoView = VideoPlayerView(frame: contentView.bounds, urlString: urlString, delegate: self)
        addViewToContentView(view: videoView)
    }
    
    private func addViewToContentView(view: UIView?) {
        guard let view = view else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            view.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
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
                print("began long press")
            } else {
                print("end")
            }
        }
    }
}

extension SnapPreviewCell: VideoPlayerViewDelegate {
    func videoDidEnd() {
        
    }
}
