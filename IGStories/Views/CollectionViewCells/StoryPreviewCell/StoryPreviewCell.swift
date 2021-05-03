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
    //MARK: - IBOutlets
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    //MARK: - Variables
    var storyIndex: Int = -1
    private var snaps: [IGSnap] = []
    private var lastSeenSnapIndex: Int = -1
    private var collectionView: UICollectionView?
    
    weak var delegate: StoryPreviewCellDelegate?
    
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
    
    //MARK: - IBActions
    @IBAction func closeButtonAction(_ sender: UIButton) {
        delegate?.closeButtonPressed()
    }
    
    //MARK: - Functions
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width,
                             height: mainView.frame.height)
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
        collectionView?.register(SnapPreviewCell.self, forCellWithReuseIdentifier: "snapcell")
        
        guard let collectionView = collectionView else { return }
        
        mainView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: mainView.topAnchor),
            collectionView.heightAnchor.constraint(equalTo: mainView.heightAnchor)
        ])
    }
    
    func configure() {
        setupCollectionView()
        
        let story = StoryManager.shared.getStory(for: storyIndex)
        
        let user = story.user
        profilePictureImageView.loadImageFromUrl(urlString: user.profilePicUrl)
        usernameLabel.text = user.username
        
        snaps = story.snaps
        lastSeenSnapIndex = story.lastSeenSnapIndex
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension StoryPreviewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return snaps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "snapcell", for: indexPath) as! SnapPreviewCell
        cell.snapIndex = indexPath.row
        cell.delegate = self
        cell.configure(storyIndex: storyIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SnapPreviewCell {
            cell.configure(storyIndex: storyIndex)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SnapPreviewCell {
            cell.prepareForReuse()
        }
    }
}

//MARK: - Cubic transition functions
extension StoryPreviewCell {
    override open func prepareForReuse() {
        super.prepareForReuse()
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let cubicAttributes = layoutAttributes as? CubicCollectionViewLayoutAttributes else {
            fatalError("LayoutAttributes of class CubicCollectionViewLayoutAttributes expected")
        }
        layer.anchorPoint = cubicAttributes.anchorPoint
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
                collectionView?.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .centeredHorizontally, animated: true)
            }
            
        case .backward:
            if index == 0 {
                delegate?.move(.backward, storyIndex)
            } else {
                collectionView?.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
}
