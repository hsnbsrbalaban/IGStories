//
//  StoryCell.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import UIKit

class StoryPreviewCell: UICollectionViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    //MARK: - Variables
    var user: IGUser?
    var stories: [IGStory] = []
    
    var collectionView: UICollectionView?
    
    //MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialize collection view
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = mainView.frame.size
        
        collectionView = UICollectionView(frame: mainView.frame, collectionViewLayout: layout)
        
        collectionView?.register(<#T##cellClass: AnyClass?##AnyClass?#>, forCellWithReuseIdentifier: <#T##String#>)

    }
    
    //MARK: - IBActions
    
    //MARK: - Functions
    func configure(data: IGStories) {
        self.stories = data.stories
        self.user = data.user
    }

}

extension StoryPreviewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
}
