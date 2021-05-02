//
//  StoryPreviewViewController.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import UIKit

class StoryPreviewViewController: UIViewController {
    
    var selectedIndex: Int?
    
    private var igStories: [IGStory] = StoryManager.shared.getStoriesArray()
    
//    private lazy var layout: UICollectionViewFlowLayout = {
//        let ly = UICollectionViewFlowLayout()
//        ly.itemSize = CGSize(width: view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
//                             height: (view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom))
//        ly.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        ly.minimumInteritemSpacing = 0
//        ly.minimumLineSpacing = 0
//        ly.scrollDirection = .horizontal
//        return ly
//    }()
    
    private lazy var cubicLayout = CubicCollectionViewLayout()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: cubicLayout)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.backgroundColor = .clear
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(UINib(nibName: "StoryPreviewCell", bundle: nil), forCellWithReuseIdentifier: "previewcell")
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
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
        return igStories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewcell", for: indexPath) as! StoryPreviewCell
        cell.configure(with: igStories[indexPath.row], index: selectedIndex ?? 0)
        print(indexPath.row)
        print(igStories[indexPath.row].id)
        print("+++")
        return cell
    }
}
