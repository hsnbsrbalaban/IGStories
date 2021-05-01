//
//  StoryCell.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import UIKit

class StoryCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
