//
//  StoryPreviewViewController.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 1.05.2021.
//

import UIKit
import AnimatedCollectionViewLayout

/**
 Contains stories collection view
 */
class StoryPreviewViewController: UIViewController {
    //MARK: - Variables
    /**
     User's selection index. Set by `HomeViewController` during presentation.
     */
    var selectedIndex: Int = 0
    /**
     The selected index shoul be checked only once. This flag will be set to false after the first check.
     */
    private var shouldCheckSelectedIndex = true
    /**
     Get the stories array from `StoryManager`
     */
    private var igStories: [IGStory] = StoryManager.shared.getStories()

    private var collectionView: UICollectionView?
    
    //MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        // Create animated layout and set its animator to cube attributes animator
        let layout = AnimatedCollectionViewLayout()
        layout.animator = CubeAttributesAnimator()
        layout.itemSize = CGSize(width: view.bounds.size.width,
                                 height: view.bounds.size.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        // Create the stories collection view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.isPagingEnabled = true
        collectionView?.isScrollEnabled = false
        collectionView?.isPrefetchingEnabled = false
        collectionView?.backgroundColor = .clear
        // Set the delegates and register the StoryPreviewCell
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(UINib(nibName: StoryPreviewCell.identifier, bundle: nil), forCellWithReuseIdentifier: StoryPreviewCell.identifier)
        // Add collection view as subview and set its constraints
        guard let collectionView = collectionView else { return }
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        ])
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension StoryPreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return igStories.count
    }
    /**
     - NOTE: The configure function of the collection view cells are called in `willDisplay` function. Not in `cellForItemAt`.
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryPreviewCell.identifier, for: indexPath) as! StoryPreviewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Check for the selected index and scroll to that position.
        // This check is done only once (only in the first appearing).
        if selectedIndex != 0, shouldCheckSelectedIndex {
            shouldCheckSelectedIndex = false
            collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
            
            if indexPath.row == 0 {
                return
            }
        }
        // Clear the cell's content and re-configure it.
        cell.prepareForReuse()
        if let cell = cell as? StoryPreviewCell {
            cell.configure(storyIndex: indexPath.row, delegate: self)
        }
    }
}

//MARK: - StoryPreviewCellDelegate
extension StoryPreviewViewController: StoryPreviewCellDelegate {
    /**
     Checks the given direction index. Scrolls the collection view forward or backward according to parameters. Dismisses the view if there are no stories left.
     - Parameters:
        - direction: Movement direction. (.forward or .backward)
        - index: Story index
     */
    func move(_ direction: MovementDirection, _ index: Int) {
        switch direction {
        case .forward:
            if index + 1 < igStories.count {
                collectionView?.scrollToItem(at: IndexPath(item: index + 1, section: 0), at: .centeredHorizontally, animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        case .backward:
            if index > 0 {
                collectionView?.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    /**
     Dismisses the view
     */
    func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}
