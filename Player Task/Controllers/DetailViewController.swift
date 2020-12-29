//
//  DetailViewController.swift
//  Player Task
//
//  Created by Vijay Guruju on 19/12/20.
//  Copyright © 2020 V2Apps. All rights reserved.
//

import UIKit
import AVKit

class DetailViewController: UIViewController {

    //var playerContainerView: UIView!
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var totalTimeLbl: UILabel!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var thumbImgView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var hasGoneFullScreen = false
    fileprivate var isPlaying = false
    fileprivate var originalFrame = CGRect.zero

    
    
    private var player = AVQueuePlayer()
    // Reference for the player view.
  // private var playerView: PlayerView!
    private var playerView = UIView()
    var timeObserver: Any?

    var videos = [Videos]()
    var videoURL = ""
    var thumbImgUrl = ""
    var thumbImage = UIImage()
    var videoTitle = ""
    var videoDesc = ""
    var descriptionLabel = UILabel()
    // URL for the test video.
    private let player1 = AVQueuePlayer()
    
    //PLayer's
    private var playerItemContext = 0
    // Keep the reference and use it to observe the loading status.
    private var playerItem: AVPlayerItem?
    private var videoDuration: CMTime?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       // setUpPlayerContainerView()
        setUpPlayerView()
        playerContainerView.sendSubviewToBack(playerView)
        //playVideo()
        tableView.register(UINib(nibName: "VideosTableViewCell", bundle: nil), forCellReuseIdentifier: "VideosTableViewCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableView.automaticDimension
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)

        updateDetails()

    }
    override func viewDidAppear(_ animated: Bool) {
           // self.setupVideoPlayer()
//        slider.value = 0.5
//
//        let currentTime = player.currentTime()
//        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
//        slider.value = Float(currentTimeInSeconds)
//        let value = Float64(slider.value) * CMTimeGetSeconds(currentTime)
//        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
//        player.seek(to: seekTime )
    }
    override func viewWillDisappear(_ animated: Bool) {
        player.pause()
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.isSelected = false

        guard let duration = player.currentItem?.currentTime() else { return }
        self.videoDuration = duration
        let currentTimeInSeconds = CMTimeGetSeconds(duration)
        UserDefaults.standard.set(currentTimeInSeconds, forKey: "duration")
        UserDefaults.standard.synchronize()
    }
   
    
    //setting up player layer
    private func setUpPlayerView() {
        
        playerContainerView.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor).isActive = true
        playerView.heightAnchor.constraint(equalTo: playerContainerView.widthAnchor, multiplier: 16/9).isActive = true
        playerView.centerYAnchor.constraint(equalTo: playerContainerView.centerYAnchor).isActive = true
    }
   
    //MARK:- Player Setup

    func setupVideoPlayer() {
    
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds;
        playerView.layer.addSublayer(playerLayer)
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
    
    //update image from previous screen
    func updateDetails(){
        self.thumbImgView.image = thumbImage
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        self.thumbImgView.isHidden = true

        //guard let player = self.player else { return }
        if !playButton.isSelected{//.isPlaying {
            //player.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playButton.isSelected = true
            Utility.shared.showActivityIndicator(view: self.playerContainerView, target: self.playerView)
            setupVideoPlayer()
        } else {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
            playButton.isSelected = false

        }
    }

    
    //MARK:- Add All Video in Loop
    func addAllVideos(){

        //Getting duplicate url from list and add in queue
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
                    self.player.insert(loopItem, after: self.player.items().last)
                }
            }
        }
    }
   //MARK:- Update seek slider value and time label

    func updateVideoPlayerSlider() {
        
        let currentTime = player.currentTime()
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        slider.value = Float(currentTimeInSeconds)
        
        if let currentItem = player.currentItem {
            let duration = currentItem.duration
            if (CMTIME_IS_INVALID(duration)) {
                return;
            }
            let currentTime = currentItem.currentTime()
            slider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
            
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
            
            totalTimeLbl.text = "\(minsStr):\(secsStr)"
        }
        
        
    }
    
    @IBAction func seekSliderAction(_ sender: UISlider) {
        guard let duration = player.currentItem?.duration else { return }
        let value = Float64(slider.value) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        player.seek(to: seekTime )
    }
    @IBAction func fullScreenBtnClicked(_ sender: Any) {
        
        let fullVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "FullScreenVideoViewController") as! FullScreenVideoViewController
       // self.navigationController?.show(fullVC, sender: self)
        fullVC.videoURL = self.videoURL
        fullVC.videos = self.videos
        //fullVC.player.item = self.player.items()
        //fullVC.player.seek(to: self.player.currentTime())
        fullVC.seekTime = player.currentTime()
        fullVC.modalPresentationStyle = .fullScreen
        self.present(fullVC, animated: false, completion: nil)

    }
    
    
    
    //Deinitialize and remove player data
    deinit {
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        player.removeAllItems()
        print("deinit of PlayerView")
    }
    
    
}


extension DetailViewController: UITableViewDataSource,UITableViewDelegate {
    
    //MARK:- TableView Methods for Related Videos 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0,1://title , description
            return 1
        case 2: // videos list
            return self.videos.count
        default:
            return 0
        }
        
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 2{//Related videos
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideosTableViewCell") as! VideosTableViewCell

            let videoData = self.videos[indexPath.row]
            cell.titleLbl.text = videoData.title
            cell.descLbl.text = videoData.description
            cell.tag = indexPath.row
            cell.thumbImgView.sd_setImage(with: URL(string: videoData.thumb), placeholderImage: UIImage(named: "placeholder"))
        return cell

        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

            if indexPath.section == 1{//Description
                cell?.textLabel?.text = self.videoDesc
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell?.textLabel?.numberOfLines = 0
            }
            if indexPath.section == 0{//Title
                cell?.textLabel?.text = self.videoTitle
                cell?.textLabel?.textAlignment = .center
                cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)

            }
            return cell!
            
        }
    }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 2{
            let header = UIView(frame: CGRect(x: 10, y: 0, width: tableView.frame.width, height: 30))
            let headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.frame.width, height: 30))
            headerLabel.text = "Related"
            headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
            header.backgroundColor = .secondarySystemBackground
            header.addSubview(headerLabel)
            return header
        }
        else{
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2{
            return 30
        }
        else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2{
            return 150
        }else{
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if indexPath.section == 2{
                
        let videoData = self.videos[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as? VideosTableViewCell
        self.videoURL = videoData.url
        self.videoTitle = videoData.title
        self.videoDesc = videoData.description
        if let thumbImage = cell?.thumbImgView.image{
            self.thumbImage = thumbImage
        }

        self.tableView.reloadData()
       // setupVideoPlayer()
        updateDetails()
        }
        else {
            return
        }

    }
}


extension DetailViewController{
    
    //MARK:- PlayerItem observers
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
    
    private func setUpPlayerItem(with asset: AVAsset) {
        
        playerItem = AVPlayerItem(asset: asset)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
            
        DispatchQueue.main.async { [weak self] in
            //self?.player = AVPlayer(playerItem: self?.playerItem!)
            self?.player.insert(self!.playerItem!, after: self?.player.items().last)

        }
    }

    
    
}


extension CGAffineTransform {

    static let ninetyDegreeRotation = CGAffineTransform(rotationAngle: CGFloat(M_PI / 2))
}

extension AVPlayerLayer {

    var fullScreenAnimationDuration: TimeInterval {
        return 0.15
    }

    func minimizeToFrame(_ frame: CGRect) {
        UIView.animate(withDuration: fullScreenAnimationDuration) {
            self.setAffineTransform(.identity)
            self.frame = frame
        }
    }

    func goFullscreen() {
        UIView.animate(withDuration: fullScreenAnimationDuration) {
            self.setAffineTransform(.ninetyDegreeRotation)
            self.frame = UIScreen.main.bounds
            
        }
    }
}
