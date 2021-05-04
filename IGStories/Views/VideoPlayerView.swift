//
//  VideoPlayerView.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 3.05.2021.
//

import UIKit
import AVKit

protocol VideoPlayerViewDelegate: class {
    func videoDidEnd()
}

class VideoPlayerView: UIView {
    //MARK: - Variables
    private var avPlayer: AVPlayer?
    private var avLayer: AVPlayerLayer?
    private weak var delegate: VideoPlayerViewDelegate?
    
    //MARK: - Initializer & Deinitializer
    init(frame: CGRect, urlString: String, delegate: VideoPlayerViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        
        //TODO: Change this to online url
        if let _ = URL(string: urlString) {
            avPlayer = AVPlayer()
            
            guard let vp = avPlayer else { return }
            avLayer = AVPlayerLayer(player: vp)
            avLayer?.frame = bounds
            avLayer?.videoGravity = .resizeAspect
            
            guard let vl = avLayer else { return }
            layer.addSublayer(vl)

            NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            
            if let filePath = Bundle.main.path(forResource: "test", ofType: "mov") {
                let url = URL(fileURLWithPath: filePath)
                let avItem = AVPlayerItem(url: url)
                vp.replaceCurrentItem(with: avItem)
                vp.play()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Deallocate avPlayer and avLayer
    deinit {
        avPlayer?.pause()
        avLayer?.player = nil
        avLayer?.removeFromSuperlayer()
        avPlayer = nil
        avLayer = nil
    }
    
    //MARK: - Functions
    @objc private func videoDidEnd() {
        delegate?.videoDidEnd()
    }

}
