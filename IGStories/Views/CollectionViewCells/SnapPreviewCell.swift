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
    func startProgress(for snapIndex: Int, with duration: CMTime?)
    func pauseProgress(for snapIndex: Int)
    func resumeProgress(for snapIndex: Int)
}

class SnapPreviewCell: UICollectionViewCell {
    //MARK: - Constants
    static let identifier = "SnapPreviewCell"
    
    static let kImageTimeInterval: TimeInterval = 5.0
    
    //MARK: - Variables
    private var storyIndex: Int = -1
    private var snapIndex: Int = -1
    private var type: IGSnapType = .unknown
    
    private var imageView: UIImageView? = nil
    private var videoView: VideoPlayerView? = nil
    
    private var imageTimer: Timer? = nil
    private var imageTotalTimeInterval: TimeInterval = 0
    
    private var tapGesture: UITapGestureRecognizer?
    private var longPressGesture: UILongPressGestureRecognizer?
    
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
        
        destroyImageView()
        destroyVideoView()
        destroyTimer()
        
        imageTotalTimeInterval = 0
        delegate = nil
        
        if let tapGR = tapGesture, let lpGR = longPressGesture {
            removeGestureRecognizer(tapGR)
            removeGestureRecognizer(lpGR)
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
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let tapGR = self?.tapGesture, let longPressGR = self?.longPressGesture else { return }
            self?.addGestureRecognizer(tapGR)
            self?.addGestureRecognizer(longPressGR)
        }
        
        StoryManager.shared.updateLastSeenSnapIndex(storyIndex: storyIndex, snapIndex: snapIndex)
    }
    
    private func showImage(urlString: String) {
        imageView = UIImageView(frame: .zero)
        imageView?.contentMode = .scaleAspectFill
        
        addViewToContentView(view: imageView)
        
        imageView?.loadImageFromUrl(urlString: urlString, completion: { [weak self] result in
            guard let self = self else { return }
            if result {
                self.delegate?.startProgress(for: self.snapIndex, with: nil)
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
        let location = gesture.location(in: self)
        if location.x > bounds.width / 2 {
            destroyTimer()
            destroyVideoView()
            delegate?.move(.forward, snapIndex)
        } else {
            if snapIndex == 0 && storyIndex == 0 { return }
            destroyTimer()
            destroyVideoView()
            delegate?.move(.backward, snapIndex)
        }
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began || gesture.state == .ended {
            if gesture.state == .began {
                delegate?.pauseProgress(for: snapIndex)
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
                delegate?.resumeProgress(for: snapIndex)
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
        imageTimer = Timer.scheduledTimer(withTimeInterval: SnapPreviewCell.kImageTimeInterval - imageTotalTimeInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            self.delegate?.move(.forward, self.snapIndex)
        }
    }
    
    func destroyTimer() {
        imageTimer?.invalidate()
        imageTimer = nil
    }
}

//MARK: - VideoPlayerViewDelegate & Video Functions
extension SnapPreviewCell: VideoPlayerViewDelegate {
    func videoDidStart(with duration: CMTime?) {
        delegate?.startProgress(for: snapIndex, with: duration)
    }
    
    func videoDidEnd() {
        delegate?.move(.forward, snapIndex)
    }
}
