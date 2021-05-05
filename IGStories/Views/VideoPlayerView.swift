//
//  VideoPlayerView.swift
//  IGStories
//
//  Created by Hasan Basri Balaban on 3.05.2021.
//

import UIKit
import AVKit

protocol VideoPlayerViewDelegate: class {
    func videoDidStart(with duration: CMTime?)
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
        if let url = URL(string: urlString) {
            avPlayer = AVPlayer()
            
            guard let vp = avPlayer else { return }
            avLayer = AVPlayerLayer(player: vp)
            avLayer?.frame = bounds
            avLayer?.videoGravity = .resizeAspect
            
            guard let vl = avLayer else { return }
            layer.addSublayer(vl)
            
            avPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            
            let avItem = AVPlayerItem(url: url)
            vp.replaceCurrentItem(with: avItem)
            vp.play()
            
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Deallocate avPlayer and avLayer
    deinit {
        avPlayer?.pause()
        avPlayer?.removeObserver(self, forKeyPath: "timeControlStatus")
        avLayer?.player = nil
        avLayer?.removeFromSuperlayer()
        avPlayer = nil
        avLayer = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let avPlayer = avPlayer else { return }
        if keyPath == "timeControlStatus" {
            if avPlayer.timeControlStatus == .playing {
                delegate?.videoDidStart(with: avPlayer.currentItem?.duration)
            }
        }
    }
    
    //MARK: - Functions
    func playVideo() {
        avPlayer?.play()
    }
    
    func pauseVideo() {
        avPlayer?.pause()
    }
    
    @objc private func videoDidEnd() {
        delegate?.videoDidEnd()
    }

}
