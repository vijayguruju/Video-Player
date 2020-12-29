//
//  FullScreenVideoViewController.swift
//  Player Task
//
//  Created by Vijay Guruju on 21/12/20.
//  Copyright © 2020 V2Apps. All rights reserved.
//

import UIKit
import AVKit


class FullScreenVideoViewController: UIViewController {

    @IBOutlet weak var dismissBtn: UIButton!
    
    @IBOutlet weak var playOrPauseBtn: UIButton!
    
    @IBOutlet weak var seekSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var thumbImgView: UIImageView!
    @IBOutlet weak var playerContainerView: UIView!
    
    let videoPlayerView = UIView()
    var player = AVQueuePlayer()
    var timeObserver: Any?

    var videos = [Videos]()
    var videoURL = ""
    var thumbImgUrl = ""
    var videoTitle = ""
    var videoDesc = ""
    var descriptionLabel = UILabel()
      
    //PLayer's
    private var playerItemContext = 0
    private var playerItem: AVPlayerItem?
    private var videoDuration: CMTime?
    var seekTime:CMTime?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting video player view
        playerContainerView.sendSubviewToBack(videoPlayerView)
        playerContainerView.addSubview(videoPlayerView)
        videoPlayerView.backgroundColor = UIColor.black
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: videoPlayerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        
        playerContainerView.sendSubviewToBack(videoPlayerView)
        seekSlider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)

    }
    override func viewDidAppear(_ animated: Bool) {
        //self.setupVideoPlayer()
        player.seek(to: self.seekTime!)
    }
    override func viewWillDisappear(_ animated: Bool) {
        player.pause()
        
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
    
    
    
    @IBAction func dismissBtn(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)

    }
    
    //MARK:- Player Setup
    func setupVideoPlayer() {
    
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoPlayerView.bounds;
        videoPlayerView.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;

        
        let asset = AVURLAsset(url: URL(string: videoURL)!)
        asset.loadValuesAsynchronously(forKeys: ["duration", "playable"]) {
        let loopItem = AVPlayerItem(asset: asset)
        self.playerItem = loopItem
        loopItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &self.playerItemContext)
            DispatchQueue.main.async { [weak self] in
                self?.player.insert(loopItem, after: self?.player.items().last)
                self?.addAllVideos()
            }
        }
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in
            self.updateVideoPlayerSlider()
            
        })
            
    }
    //MARK:- Add All Video in Loop

     func addAllVideos(){

           var videoUrls = videos.map{$0.url}
           print(videoUrls)
           if videoUrls.contains(self.videoURL){
               let index = videoUrls.enumerated().filter({ $0.element == videoURL }).map({ $0.offset })
               videoUrls.remove(at: index[0])
               videoUrls.insert(videoURL, at: 0)
           }
       for video in videoUrls {
            
              let asset = AVURLAsset(url: URL(string: video)!)
                asset.loadValuesAsynchronously(forKeys: ["duration", "playable"]) {
                    let loopItem = AVPlayerItem(asset: asset)

                    loopItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &self.playerItemContext)
                    self.playerItem = loopItem

                    DispatchQueue.main.async {
                        let loopItem = AVPlayerItem(asset: asset)
                        self.player.insert(loopItem, after: self.player.items().last)
                    }
                }
            }
        }
    
//MARK:- Update seek slider value and time label
    func updateVideoPlayerSlider() {
            
        let currentTime = player.currentTime()
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        seekSlider.value = Float(currentTimeInSeconds)
        
        if let currentItem = player.currentItem {
            let duration = currentItem.duration
            if (CMTIME_IS_INVALID(duration)) {
                return;
            }
            let currentTime = currentItem.currentTime()
            seekSlider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
            
            // Update time remaining label
            let totalTimeInSeconds = CMTimeGetSeconds(duration)
            let remainingTimeInSeconds = totalTimeInSeconds - currentTimeInSeconds
            let mins = remainingTimeInSeconds / 60
            let secs = remainingTimeInSeconds.truncatingRemainder(dividingBy: 60)
            let timeformatter = NumberFormatter()
            timeformatter.minimumIntegerDigits = 2
            timeformatter.minimumFractionDigits = 0
            timeformatter.roundingMode = .down
            guard let minsStr = timeformatter.string(from: NSNumber(value: mins)), let secsStr = timeformatter.string(from: NSNumber(value: secs)) else {
                return
            }
            
            timeLabel.text = "\(minsStr):\(secsStr)"
        }
            
            
    }
        

    @IBAction func playOrPauseBtnAction(_ sender: UIButton) {
        self.thumbImgView.isHidden = true

        //guard let player = self.player else { return }
       if !sender.isSelected{//.isPlaying {
           //player.play()
           playOrPauseBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
           sender.isSelected = true
           Utility.shared.showActivityIndicator(view: self.playerContainerView, target: self.videoPlayerView)
           setupVideoPlayer()
       } else {
           playOrPauseBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
           player.pause()
           sender.isSelected = false

       }
        
    }
    
    @IBAction func seekSliderValueChange(_ sender: Any) {
        guard let duration = player.currentItem?.duration else { return }
        let value = Float64(seekSlider.value) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        player.seek(to: seekTime )
    }

deinit {
    playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    player.removeAllItems()
    print("deinit of PlayerView")
}
    
}
    
extension FullScreenVideoViewController{
    
    
    //MARK:- Player item status observers
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
            
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // Switch over status value
            switch status {
            case .readyToPlay:
                print(".readyToPlay")
                player.play()
                Utility.shared.hideActivityIndicator(view: self.playerContainerView)

            case .failed:
                print(".failed")
            case .unknown:
                print(".unknown")
            @unknown default:
                print("@unknown default")
            }
        }
    }
    
    private func setUpAsset(with url: URL, completion: ((_ asset: AVAsset) -> Void)?) {
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                completion?(asset)
            case .failed:
                print(".failed")
            case .cancelled:
                print(".cancelled")
            default:
                print("default")
            }
        }
    }
    
    
    
    
}


