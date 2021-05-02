//
//  ViewController.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var igStories: [IGStory] = StoryManager.shared.getStoriesArray()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let ly = UICollectionViewFlowLayout()
        ly.itemSize = CGSize(width: 60, height: 81)
        ly.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        ly.scrollDirection = .horizontal
        return ly
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.7411764706, blue: 0.631372549, alpha: 1)
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(HomeViewCell.self, forCellWithReuseIdentifier: "homeviewcell")
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
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return igStories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HomeViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeviewcell", for: indexPath) as! HomeViewCell
        cell.setupUI(imageUrlString: igStories[indexPath.row].user.profilePicUrl, username: igStories[indexPath.row].user.username)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = StoryPreviewViewController.init()
        vc.selectedIndex = indexPath.row
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}
