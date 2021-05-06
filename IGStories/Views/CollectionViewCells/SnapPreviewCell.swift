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
    /// Starts the animation of the related progress bar
    func didDisplayImage(_ snapIndex: Int)
    /// Starts the animation of the related progress bar
    func didDisplayVideo(_ snapIndex: Int, with duration: CMTime?)
    /// Stops the animation of the related progress bar
    func pauseProgress(for snapIndex: Int)
    /// Continues the animation of the related progress bar
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
    /**
     Clear every stored property to its default value.
     */
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
    /**
     Configure the cell with the given indexes.
     - Parameters:
        - storyIndex: The index of the cells story.
        - snapIndex: The index of the cell snap
        - delegate: Cell's delegate.
     */
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
        
        // Create gestures
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        
        ///- NOTE: The last seen snap index for the stories are updated here. It passes +1 as the index, this is intended and handled in `StoryManager`.
        StoryManager.shared.updateLastSeenSnapIndex(storyIndex: storyIndex, snapIndex: snapIndex + 1)
    }
    /**
     Creates `imageView` and adds it to `contentView`. Notifies the delegate when it is done.
     - Parameter urlString: String for the url of the desired image.
     */
    private func showImage(urlString: String) {
        imageView = UIImageView(frame: .zero)
        imageView?.contentMode = .scaleAspectFit
        
        addViewToContentView(view: imageView)
        
        imageView?.loadImageFromUrl(urlString: urlString, completion: { [weak self] result in
            guard let self = self else { return }
            if result {
                self.addGestures()
                self.delegate?.didDisplayImage(self.snapIndex)
            }
        })
    }
    /**
     Cretes `videoView` and adds it to `contentView`. Notification of the delegate is done in `VideoPlayerViewdelegate` functions.
     - Parameter urlString: String for the url of the desired image.
     */
    private func showVideo(urlString: String) {
        videoView = VideoPlayerView(frame: contentView.bounds, urlString: urlString, delegate: self)
        addViewToContentView(view: videoView)
    }
    /**
     Adds the given to `contentView` as subview.
     - Parameter view: UIView
     */
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
    /**
     Removes the `imageView` from its superview.
     */
    private func destroyImageView() {
        imageView?.image = nil
        imageView?.removeFromSuperview()
        imageView = nil
    }
    /**
     Removes the `videoView` from its superview.
     */
    private func destroyVideoView() {
        videoView?.removeFromSuperview()
        videoView = nil
    }
}

//MARK: - Gesture Functions
extension SnapPreviewCell {
    /**
     Notifies the delegate to move forward or backward between snaps according to the touch location.
     */
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
    /**
     Notifies the delegate to stop or continue to animate the related progress bar.
     */
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
    /**
     Notifies the delegate to move forward or backward between stories according to the swipe direction.
     */
    @objc func didSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            destroyVideoView()
            delegate?.moveToStory(.forward)
        } else if gesture.direction == .right {
            if storyIndex == 0 { return }
            destroyVideoView()
            delegate?.moveToStory(.backward)
        }
    }
    /**
     Add gestures to the `contentView`. This is called when the image or the video displayed successfully.
     */
    private func addGestures() {
        guard let tapGR = self.tapGesture,
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
}

//MARK: - VideoPlayerViewDelegate & Video Functions
extension SnapPreviewCell: VideoPlayerViewDelegate {
    /**
     Add gestures to `contentView` and notify the delegate to start animating the corresponding progress bar.
     */
    func videoDidStart(with duration: CMTime?) {
        addGestures()
        delegate?.didDisplayVideo(snapIndex, with: duration)
    }
}
