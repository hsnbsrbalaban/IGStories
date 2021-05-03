//
//  StoryPreviewViewController.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import UIKit

class StoryPreviewViewController: UIViewController {
    //MARK: - Variables
    var selectedIndex: Int?
    private var collectionView: UICollectionView?
    private var igStories: [IGStory] = StoryManager.shared.getStories()

    //MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let layout = CubicCollectionViewLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.isPagingEnabled = true
        collectionView?.isScrollEnabled = false
        collectionView?.backgroundColor = .clear
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(UINib(nibName: "StoryPreviewCell", bundle: nil), forCellWithReuseIdentifier: "previewcell")
        
        guard let collectionView = collectionView else { return }
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let selectedIndex = selectedIndex {
            collectionView?.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension StoryPreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return igStories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewcell", for: indexPath) as! StoryPreviewCell
        cell.storyIndex = indexPath.row
        cell.delegate = self
        cell.configure()
        return cell
    }
}

extension StoryPreviewViewController: StoryPreviewCellDelegate {
    func move(_ direction: MovementDirection, _ index: Int) {
        switch direction {
        case .forward:
            if index + 1 < igStories.count {
                collectionView?.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .centeredHorizontally, animated: true)
            }
        case .backward:
            if index != 0 {
                collectionView?.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}
