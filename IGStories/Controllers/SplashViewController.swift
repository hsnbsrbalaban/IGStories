//
//  SplashViewController.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 5.05.2021.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            let vc = HomeViewController.init()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }
}
