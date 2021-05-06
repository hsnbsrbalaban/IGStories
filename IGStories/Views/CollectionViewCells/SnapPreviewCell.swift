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
    /// Move between stories (swipe gesture)
    func moveToStory(_ direction: MovementDirection)
    
    func didDisplayImage(_ snapIndex: Int)
    
    func didDisplayVideo(_ snapIndex: Int, with duration: CMTime?)

    func pauseProgress(for snapIndex: Int)
    
    func resumeProgress(for snapIndex: Int)
}

class SnapPreviewCell: UICollectionViewCell {
    //MARK: - Constants
    static let identifier = "SnapPreviewCell"
    
    //MARK: - Variables
    private var storyIndex: Int = -1
    private var snapIndex: Int = -1
    private var type: IGSnapType = .unknown
    
    private var imageView: UIImageView? = nil
    private var videoView: VideoPlayerView? = nil
    
    private var tapGesture: UITapGestureRecognizer?
    private var longPressGesture: UILongPressGestureRecognizer?
    private var leftSwipeGesture: UISwipeGestureRecognizer?
    private var rightSwipeGesture: UISwipeGestureRecognizer?
    
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
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        storyIndex = -1
        snapIndex = -1
        type = .unknown
        delegate = nil
        destroyImageView()
        destroyVideoView()
        if let tapGR = tapGesture, let lpGR = longPressGesture,
           let lsGR = leftSwipeGesture, let rsGR = rightSwipeGesture {
            removeGestureRecognizer(tapGR)
            removeGestureRecognizer(lpGR)
            removeGestureRecognizer(lsGR)
            removeGestureRecognizer(rsGR)
        }
    }
    
    //MARK: - Functions
    func configure(storyIndex: Int, snapIndex: Int, delegate: SnapPreviewCellDelegate) {
        self.storyIndex = storyIndex
        self.snapIndex = snapIndex
        self.delegate = delegate

        let snap = StoryManager.shared.getSnap(for: storyIndex, snapIndex: snapIndex)
        type = snap.type
        
        switch snap.type {
        case .image:
            showImage(urlString: snap.mediaUrl)
        case .video:
            showVideo(urlString: snap.mediaUrl)
        case .unknown:
            fatalError("Unknown media type!")
        }
        
        // Add gestures
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self,
                  let tapGR = self.tapGesture,
                  let longPressGR = self.longPressGesture,
                  let lsGR = self.leftSwipeGesture,
                  let rsGR = self.rightSwipeGesture else { return }
            lsGR.direction = .left
            rsGR.direction = .right
            self.addGestureRecognizer(tapGR)
            self.addGestureRecognizer(longPressGR)
            self.addGestureRecognizer(lsGR)
            self.addGestureRecognizer(rsGR)
        }
        
        StoryManager.shared.updateLastSeenSnapIndex(storyIndex: storyIndex, snapIndex: snapIndex + 1)
    }
    
    private func showImage(urlString: String) {
        imageView = UIImageView(frame: .zero)
        imageView?.contentMode = .scaleAspectFit
        
        addViewToContentView(view: imageView)
        
        imageView?.loadImageFromUrl(urlString: urlString, completion: { [weak self] result in
            guard let self = self else { return }
            if result {
                self.delegate?.didDisplayImage(self.snapIndex)
            }
        })
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
    
    private func destroyImageView() {
        imageView?.image = nil
        imageView?.removeFromSuperview()
        imageView = nil
    }
    
    private func destroyVideoView() {
        videoView?.removeFromSuperview()
        videoView = nil
    }
}

//MARK: - Gesture Functions
extension SnapPreviewCell {
    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if location.x > bounds.width / 2 {
            destroyVideoView()
            delegate?.move(.forward, snapIndex)
        } else {
            if snapIndex == 0 && storyIndex == 0 { return }
            destroyVideoView()
            delegate?.move(.backward, snapIndex)
        }
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began || gesture.state == .ended {
            if gesture.state == .began {
                delegate?.pauseProgress(for: snapIndex)
                
                if type == .video {
                    videoView?.pauseVideo()
                }
            } else {
                delegate?.resumeProgress(for: snapIndex)
                
                if type == .video {
                    videoView?.playVideo()
                }
            }
        }
    }
    
    @objc func didSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            delegate?.moveToStory(.forward)
        } else if gesture.direction == .right {
            delegate?.moveToStory(.backward)
        }
    }
}

//MARK: - VideoPlayerViewDelegate & Video Functions
extension SnapPreviewCell: VideoPlayerViewDelegate {
    func videoDidStart(with duration: CMTime?) {
        delegate?.didDisplayVideo(snapIndex, with: duration)
    }
}
