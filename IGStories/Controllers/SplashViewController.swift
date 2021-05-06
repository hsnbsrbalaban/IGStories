//
//  SplashViewController.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 5.05.2021.
//

import UIKit

/**
 Used for locking the screen orientation.
 */
class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Lock orientation to portrait mode only
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        // Show splash screen for 3 seconds and present HomeViewController
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            let vc = HomeViewController.init()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }
}
