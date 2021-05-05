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
    func longPressBegan(for snapIndex: Int)
    /// Inform the delegate that long press gesture ended
    func longPressEnded(for snapIndex: Int)
}

class SnapPreviewCell: UICollectionViewCell {
    //MARK: - Constants
    static let identifier = "SnapPreviewCell"
    
    static let kImageTimeInterval: TimeInterval = 5.0
    
    //MARK: - Variables
    private var snapIndex: Int = -1
    private var type: IGSnapType = .unknown
    
    private var imageView: UIImageView? = nil
    private var videoView: VideoPlayerView? = nil
    
    private var imageTimer: Timer? = nil
    private var imageTotalTimeInterval: TimeInterval = 0
    
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
        type = .unknown
        
        destroyImageView()
        destroyVideoView()
        destroyTimer()
        
        imageTotalTimeInterval = 0
        delegate = nil
    }
    
    //MARK: - Functions
    func configure(storyIndex: Int, snapIndex: Int, delegate: SnapPreviewCellDelegate) {
        self.snapIndex = snapIndex
        self.delegate = delegate
        print("in configure for story: \(storyIndex) , snap: \(snapIndex)")
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
    }
    
    private func showImage(urlString: String) {
        imageView = UIImageView(frame: .zero)
        imageView?.contentMode = .scaleAspectFill
        
        addViewToContentView(view: imageView)
        
        imageView?.loadImageFromUrl(urlString: urlString, completion: { [weak self] result in
            guard let self = self else { return }
            if result {
                self.startOrResumeTimer()
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
        destroyTimer()
        destroyVideoView()
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
                delegate?.longPressBegan(for: snapIndex)
                switch type {
                case .image:
                    if let timer = imageTimer {
                        imageTotalTimeInterval += timer.fireDate.timeIntervalSinceNow
                    }
                    imageTimer?.invalidate()
                case .video:
                    videoView?.pauseVideo()
                case .unknown:
                    fatalError("Unknown media type!")
                }
            } else {
                delegate?.longPressEnded(for: snapIndex)
                switch type {
                case .image:
                    startOrResumeTimer()
                case .video:
                    videoView?.playVideo()
                case .unknown:
                    fatalError("Unknown media type!")
                }
            }
        }
    }
}

//MARK: - Timer Functions
extension SnapPreviewCell {
    private func startOrResumeTimer() {
        print("Start or resume timer")
        imageTimer = Timer.scheduledTimer(withTimeInterval: SnapPreviewCell.kImageTimeInterval - imageTotalTimeInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            self.delegate?.move(.forward, self.snapIndex)
        }
    }
    
    func destroyTimer() {
        print("Destroy timer")
        imageTimer?.invalidate()
        imageTimer = nil
    }
}

//MARK: - VideoPlayerViewDelegate & Video Functions
extension SnapPreviewCell: VideoPlayerViewDelegate {
    func videoDidEnd() {
        delegate?.move(.forward, snapIndex)
    }
}
