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
    private var lastSeenSnapIndex: Int = -1
    private var snaps: [IGSnap] = []
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        storyIndex = -1
        lastSeenSnapIndex = -1
        
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
        setupCollectionView()
        setupProgressBars()
    }
    
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
    
    private func setupCollectionView() {
        guard let mv = mainView else {
            fatalError("main view is not created!")
        }

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: mv.bounds.width,
                                 height: mv.bounds.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.isPagingEnabled = true
        collectionView?.isScrollEnabled = false
        collectionView?.backgroundColor = .clear
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(SnapPreviewCell.self, forCellWithReuseIdentifier: SnapPreviewCell.identifier)
        
        guard let collectionView = collectionView else { return }
        mv.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.trailingAnchor.constraint(equalTo: mv.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: mv.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: mv.topAnchor),
            collectionView.heightAnchor.constraint(equalTo: mv.heightAnchor)
        ])
    }
    
    private func setupProgressBars() {
        guard let pv = progressView else {
            fatalError("progress view is not created!")
        }
        
        let width = (pv.frame.width / CGFloat(snaps.count)) - 2
        let height = pv.bounds.height * 0.5
        
        var i: CGFloat = 0
        for snap in snaps {
            switch snap.type {
            case .image:
                let sbp = SegmentedProgressBar(numberOfSegments: 1, duration: SnapPreviewCell.kImageTimeInterval)
                sbp.frame = CGRect(x: (width * i) + (2 * i), y: 0, width: width, height: height)
                sbp.topColor = .white
                sbp.bottomColor = UIColor.white.withAlphaComponent(0.5)
                segmentedProgressBars.append(sbp)
                pv.addSubview(sbp)
                
            case .video:
                let duration = snap.duration ?? 1
                let sbp = SegmentedProgressBar(numberOfSegments: 1, duration: duration)
                sbp.frame = CGRect(x: (width * i) + (2 * i), y: 0, width: width, height: height)
                sbp.topColor = .white
                sbp.bottomColor = UIColor.white.withAlphaComponent(0.5)
                segmentedProgressBars.append(sbp)
                pv.addSubview(sbp)
            
            case .unknown:
                fatalError("unknown media type")
            }
            i += 1
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension StoryPreviewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return snaps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SnapPreviewCell.identifier, for: indexPath) as! SnapPreviewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.prepareForReuse()
        if let cell = cell as? SnapPreviewCell {
            cell.configure(storyIndex: storyIndex, snapIndex: indexPath.row, delegate: self)
        }
    }
}

//MARK: - SnapPreviewCellDelegate
extension StoryPreviewCell: SnapPreviewCellDelegate {
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
                //Stop the current one
                segmentedProgressBars[index].rewind()
                segmentedProgressBars[index].isPaused = true
                //Reset the previous one
                segmentedProgressBars[index-1].rewind()
                segmentedProgressBars[index-1].isPaused = true
                
                collectionView?.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }
    
    func startProgress(for snapIndex: Int, with duration: CMTime?) {
        if snapIndex < snaps.count {
            if duration != nil {
                let time = CMTimeGetSeconds(duration!)
                segmentedProgressBars[snapIndex].updateDuration(duration: Double(time))
            }
            
            segmentedProgressBars[snapIndex].rewind()
        }
    }
    
    func pauseProgress(for snapIndex: Int) {
        if snapIndex < snaps.count {
            segmentedProgressBars[snapIndex].isPaused = true
        }
    }
    
    func resumeProgress(for snapIndex: Int) {
        if snapIndex < snaps.count {
            segmentedProgressBars[snapIndex].isPaused = false
        }
    }
}
