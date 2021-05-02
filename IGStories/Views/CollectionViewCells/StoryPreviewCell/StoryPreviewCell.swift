//
//  StoryCell.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import UIKit
import AVKit

protocol StoryPreviewCellDelegate: class {
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
    private var snaps: [IGSnap] = []
    private var lastSeenSnapIndex: Int = -1
    
    weak var delegate: StoryPreviewCellDelegate?
    
    //MARK: - UI
    private lazy var layout: UICollectionViewFlowLayout = {
        let ly = UICollectionViewFlowLayout()
        ly.itemSize = CGSize(width: UIScreen.main.bounds.width,
                             height: mainView.frame.height)
        ly.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        ly.minimumInteritemSpacing = 0
        ly.minimumLineSpacing = 0
        ly.scrollDirection = .horizontal
        return ly
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.backgroundColor = .clear
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(SnapPreviewCell.self, forCellWithReuseIdentifier: "snapcell")
        return cv
    }()
    
    //MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: mainView.topAnchor),
            collectionView.heightAnchor.constraint(equalTo: mainView.heightAnchor)
        ])
        
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
    func configure(with story: IGStory, index: Int) {
        let user = story.user
        StoryManager.shared.loadImageFromUrl(to: profilePictureImageView, urlString: user.profilePicUrl)
        usernameLabel.text = user.username
        
        snaps = story.snaps
        lastSeenSnapIndex = story.lastSeenSnapIndex
    }
}

extension StoryPreviewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return snaps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "snapcell", for: indexPath) as! SnapPreviewCell
        cell.configure(with: snaps[indexPath.row])
        return cell
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
