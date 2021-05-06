//
//  StoryCell.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import UIKit
import AVKit

protocol StoryPreviewCellDelegate: class {
    func move(_ direction: MovementDirection, _ index: Int)
    func closeButtonPressed()
}

class StoryPreviewCell: UICollectionViewCell {
    //MARK: - Constants
    static let identifier = "StoryPreviewCell"
    
    //MARK: - IBOutlets
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    
    //MARK: - Variables
    private var storyIndex: Int = -1
    /**
     Index of the last seen snap. Get this from `StoryManager`.
     */
    private var lastSeenSnapIndex: Int = 0
    /**
     The last seen snap index shoul be checked only once. This flag will be set to false after the first check.
     */
    private var shouldCheckLastSeenIndex: Bool = true
    /**
     Get the snaps array in configure function from `StoryManager`
     */
    private var snaps: [IGSnap] = []
    /**
     The index of the currently displayed snap
     */
    private var currentSnapIndex: Int = 0
    
    private var collectionView: UICollectionView? = nil
    private var segmentedProgressBars: [SegmentedProgressBar] = []
    
    private var progressView: UIView?
    private var mainView: UIView?
    
    private weak var delegate: StoryPreviewCellDelegate?
    
    //MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.bounds.width * 0.5
        profilePictureImageView.layer.borderWidth = 2
        profilePictureImageView.layer.borderColor = #colorLiteral(red: 0.4078431373, green: 0.4745098039, blue: 0.5019607843, alpha: 1)
        profilePictureImageView.clipsToBounds = true
        
        messageTextField.backgroundColor = .clear
        messageTextField.textColor = .white
        messageTextField.layer.borderColor = UIColor.gray.cgColor
        messageTextField.layer.borderWidth = 1
        messageTextField.layer.cornerRadius = 15
    }
    /**
     Clear every stored property to its default value.
     */
    override func prepareForReuse() {
        super.prepareForReuse()
        storyIndex = -1
        lastSeenSnapIndex = 0
        shouldCheckLastSeenIndex = true
        currentSnapIndex = 0
        
        profilePictureImageView.image = nil
        usernameLabel.text = ""
        
        collectionView?.removeFromSuperview()
        collectionView = nil
        
        segmentedProgressBars.forEach({ $0.removeFromSuperview() })
        segmentedProgressBars.removeAll()
        
        progressView?.removeFromSuperview()
        progressView = nil
        
        mainView?.removeFromSuperview()
        mainView = nil
        
        delegate = nil
    }
    
    //MARK: - IBActions
    @IBAction func closeButtonAction(_ sender: UIButton) {
        delegate?.closeButtonPressed()
    }
    
    //MARK: - Functions
    /**
     Configure the cell with the given story index.
     - Parameters:
        - storyIndex: The index of the cells story.
        - delegate: Cell's delegate.
     */
    func configure(storyIndex: Int, delegate: StoryPreviewCellDelegate) {
        self.storyIndex = storyIndex
        self.delegate = delegate
        
        let story = StoryManager.shared.getStory(for: storyIndex)
        snaps = story.snaps
        lastSeenSnapIndex = story.lastSeenSnapIndex
        let user = story.user
        profilePictureImageView.loadImageFromUrl(urlString: user.profilePicUrl, completion: nil)
        usernameLabel.text = user.username
        
        setupViews()
        setupProgressBars()
        setupCollectionView()
    }
    /**
     Creates  `mainView` and `progressView` objects and adds them to cell.
     */
    private func setupViews() {
        mainView = UIView(frame: .zero)
        guard let mv = mainView else { return }
        mv.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mv)
        
        NSLayoutConstraint.activate([
            mv.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            mv.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            mv.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            mv.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -60) //60 for bottom view
        ])
        
        progressView = UIView(frame: .zero)
        guard let pv = progressView else { return }
        pv.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pv)
        
        NSLayoutConstraint.activate([
            pv.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            pv.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            pv.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            pv.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        contentView.bringSubviewToFront(pv)
        contentView.bringSubviewToFront(userView)
        layoutIfNeeded()
    }
    /**
     Creates the `collectionView` and adds it to `mainView`.
     */
    private func setupCollectionView() {
        guard let mv = mainView else {
            fatalError("main view is not created!")
        }
        // Create the collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: mv.bounds.width,
                                 height: mv.bounds.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        // Create the colelction view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.isPagingEnabled = true
        collectionView?.isScrollEnabled = false
        collectionView?.backgroundColor = .clear
        // Set the collection view's delegates and register `SnapPreviewCell`
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(SnapPreviewCell.self, forCellWithReuseIdentifier: SnapPreviewCell.identifier)
        // Add collection view to mainView
        guard let collectionView = collectionView else { return }
        mv.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.trailingAnchor.constraint(equalTo: mv.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: mv.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: mv.topAnchor),
            collectionView.heightAnchor.constraint(equalTo: mv.heightAnchor)
        ])
        layoutIfNeeded()
    }
    /**
     Creates progress bars and adds them to `progressView`.
     Creates a progress bar for each snap in the story.
     */
    private func setupProgressBars() {
        guard let pv = progressView else {
            fatalError("progress view is not created!")
        }
        
        let width = (pv.frame.width / CGFloat(snaps.count)) - 2
        let height = pv.bounds.height * 0.5
        
        var i: CGFloat = 0
        for _ in snaps {
            let sbp = SegmentedProgressBar(numberOfSegments: 1, duration: 5, index: Int(i))
            sbp.frame = CGRect(x: (width * i) + (2 * i), y: 0, width: width, height: height)
            sbp.topColor = .white
            sbp.bottomColor = UIColor.white.withAlphaComponent(0.5)
            segmentedProgressBars.append(sbp)
            pv.addSubview(sbp)
            
            i += 1
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension StoryPreviewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return snaps.count
    }
    /**
     - NOTE: The configure function of the collection view cells are called in `willDisplay` function. Not in `cellForItemAt`.
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SnapPreviewCell.identifier, for: indexPath) as! SnapPreviewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Check for the last seen snap index and scroll to that position.
        // This check is done only once (only in the first appearing).
        if lastSeenSnapIndex != 0 && shouldCheckLastSeenIndex {
            shouldCheckLastSeenIndex = false
            collectionView.scrollToItem(at: IndexPath(item: lastSeenSnapIndex, section: 0), at: .centeredHorizontally, animated: false)

            for i in 0..<lastSeenSnapIndex {
                segmentedProgressBars[i].skip()
            }
            if indexPath.row == 0 {
                return
            }
        }
        // Clear the cell's content and re-configure it.
        cell.prepareForReuse()
        if let cell = cell as? SnapPreviewCell {
            cell.configure(storyIndex: storyIndex, snapIndex: indexPath.row, delegate: self)
        }
    }
}

//MARK: - SnapPreviewCellDelegate
extension StoryPreviewCell: SnapPreviewCellDelegate {
    /**
     Checks the given direction index. Scrolls the collection view forward or backward according to parameters. Asks its delegate to move if there are no snaps left.
     - Parameters:
        - direction: Movement direction. (.forward or .backward)
        - index: Snap index
     */
    func move(_ direction: MovementDirection, _ index: Int) {
        switch direction {
        case .forward:
            if index + 1 == snaps.count {
                delegate?.move(.forward, storyIndex)
            } else {
                segmentedProgressBars[index].skip()
                collectionView?.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .centeredHorizontally, animated: false)
            }
            
        case .backward:
            if index == 0 {
                delegate?.move(.backward, storyIndex)
            } else {
                //Reset and stop the current one
                resetProgress(for: index)
                //Reset the previous one, it will then start when the image loaded
                resetProgress(for: index - 1)
                
                collectionView?.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }
    /**
     Directly asks its delegate to move to the next or previous story. Called during swipe gesture.
     - Parameter direction: The movement direction (.forward or .backward)
     */
    func moveToStory(_ direction: MovementDirection) {
        switch direction {
        case .forward:
            delegate?.move(.forward, storyIndex)
        case .backward:
            delegate?.move(.backward, storyIndex)
        }
    }
    /**
     Gets notified by the snap cell that the current cell displayed its image. Starts the animation for the related progress bar.
     - Parameter snapIndex: The index of the snap cell.
     */
    func didDisplayImage(_ snapIndex: Int) {
        currentSnapIndex = snapIndex
        segmentedProgressBars[snapIndex].delegate = self
        segmentedProgressBars[snapIndex].startAnimation()
    }
    /**
     Gets notified by the snap cell that the current cell displayed and started its video. Starts the animation for the related progress bar.
     - Parameters:
        - snapIndex: The index of the snap cell.
        - duration: Duration of the video.
     */
    func didDisplayVideo(_ snapIndex: Int, with duration: CMTime?) {
        currentSnapIndex = snapIndex
        if let duration = duration {
            let time = CMTimeGetSeconds(duration)
            segmentedProgressBars[snapIndex].delegate = self
            segmentedProgressBars[snapIndex].updateDuration(duration: time)
            segmentedProgressBars[snapIndex].startAnimation()
        }
    }
    /**
     Stops the animation of the related progress bar for the given index.
     - Parameter snapIndex: Index of the snap cell.
     */
    func pauseProgress(for snapIndex: Int) {
        segmentedProgressBars[snapIndex].isPaused = true
    }
    /**
     Continues the animation of the related progress bar for the given index.
     - Parameter snapIndex: Index of the snap cell.
     */
    func resumeProgress(for snapIndex: Int) {
        segmentedProgressBars[snapIndex].isPaused = false
    }
    /**
     Resets the animation of the related progress bar for the given index.
     - Parameter snapIndex: Index of the snap cell.
     */
    func resetProgress(for snapIndex: Int) {
        segmentedProgressBars[snapIndex].rewind()
        segmentedProgressBars[snapIndex].isPaused = true
    }
}
// MARK: - SegmentedProgressBarDelegate
extension StoryPreviewCell: SegmentedProgressBarDelegate {
    /**
     Gets notified when the current progress bar's animation ended. Removes the bar's delegate and calls `move` function.
     - Parameters:
        - index: Index of the progress bar.
        - bar: The progress bar itself.
     */
    func segmentedProgressBarFinished(index: Int, bar: SegmentedProgressBar) {
        if index == currentSnapIndex {
            bar.removeDelegate()
            move(.forward, index)
        }
    }
    
    func segmentedProgressBarChangedIndex(index: Int) { }
}
