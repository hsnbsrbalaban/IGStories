//
//  StoryPreviewViewController.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import UIKit

class StoryPreviewViewController: UIViewController {
    
    var igStory: IGStory?
    
    lazy var layout: UICollectionViewFlowLayout = {
        let ly = UICollectionViewFlowLayout()
        ly.itemSize = CGSize(width: view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
                             height: (view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)*0.75)
        ly.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        ly.scrollDirection = .horizontal
        return ly
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.7411764706, blue: 0.631372549, alpha: 1)
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(UINib(nibName: "StoryPreviewCell", bundle: nil), forCellWithReuseIdentifier: "previewcell")
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        ])

    }
}

extension StoryPreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewcell", for: indexPath) as! StoryPreviewCell
        
        
        return cell
    }
    
    
}
