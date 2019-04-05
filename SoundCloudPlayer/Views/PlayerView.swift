//
//  PlayerView.swift
//  SoundCloudPlayer
//
//  Created by Bambooks on 03/04/2019.
//  Copyright © 2019 ifeoluwa. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

var player = AVPlayer()

class PlayerView: UIView {
    
    var song: Song? {
        didSet {
            playAudio(url: (song?.media)!)
            title.text = song?.title
            miniTitle.text = song?.title
            
            var nowPlayingInfo = [String: Any]()
            
            nowPlayingInfo[MPMediaItemPropertyTitle] = song?.title
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    var posterImg: UIImage? {
        didSet {
            poster.image = posterImg
            miniPoster.image = posterImg
            
            let artwork = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { _ -> UIImage in
                return self.posterImg!
            })
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
        }
    }
    
    lazy var fullPlayerConstrainst = [
        fullStackview.topAnchor.constraint(equalTo: topAnchor),
        fullStackview.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
        fullStackview.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
        fullStackview.heightAnchor.constraint(equalTo: heightAnchor),
        poster.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.5),
        title.heightAnchor.constraint(equalToConstant: 50),
        slide.heightAnchor.constraint(equalToConstant: 23),
        closeBtn.heightAnchor.constraint(lessThanOrEqualToConstant: 20)
    ]
    
    lazy var miniPlayerConstrainst = [
        miniStackview.topAnchor.constraint(equalTo: topAnchor),
        miniStackview.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
        miniStackview.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
        miniStackview.bottomAnchor.constraint(equalTo: bottomAnchor),
        miniPoster.heightAnchor.constraint(lessThanOrEqualToConstant: 50),
        miniPoster.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
        miniTitle.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
        miniPlayBtn.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1)
    ]
    
    
    static func createPlayer() -> PlayerView {
        return PlayerView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(togglePlayerView)))
        
        setupView()
        
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self](time) in
            let totalTime = CMTimeGetSeconds(player.currentTime())
            let duration = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
            let percentage = totalTime / duration
            self?.slide.value = Float(percentage)
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = totalTime
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared().togglePlayPauseCommand
        commandCenter.isEnabled = true
        commandCenter.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            self.playPause()
            return .success
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        } catch {
            
        }

    }
    
    private func setupView() {
        addSubview(fullStackview)
        NSLayoutConstraint.activate(fullPlayerConstrainst)
    }
    
    func showFullPlayer() {
        NSLayoutConstraint.deactivate(miniPlayerConstrainst)
        miniStackview.isHidden = true
        addSubview(fullStackview)
        fullStackview.isHidden = false
        NSLayoutConstraint.activate(fullPlayerConstrainst)
    }
    
    func showMiniPlayer() {
        NSLayoutConstraint.deactivate(fullPlayerConstrainst)
        fullStackview.isHidden = true
        addSubview(miniStackview)
        miniStackview.isHidden = false
        NSLayoutConstraint.activate(miniPlayerConstrainst)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var poster: UIImageView = {
       let vw = UIImageView()
        vw.contentMode = .scaleAspectFit
        vw.clipsToBounds = true
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    var closeBtn: UIButton = {
        let vw = UIButton(type: .system)
        vw.setTitle("Minimise", for: .normal)
        vw.addTarget(self, action: #selector(togglePlayerView), for: .touchUpInside)
        return vw
    }()
    
    var title: UILabel = {
        let vw = UILabel()
        vw.numberOfLines = 0
        return vw
    }()
    
    var slide: UISlider = {
        let vw = UISlider()
        vw.minimumValue = 0
        vw.value = 0
        vw.isEnabled = true
        vw.isContinuous = true
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.addTarget(self, action: #selector(handleSlide), for: .valueChanged)
        return vw
    }()
    
    var playBtn: UIButton = {
        let vw = UIButton(type: .system)
        vw.setImage(UIImage(named: "play"), for: .normal)
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        return vw
    }()
    
    var forwardBtn: UIButton = {
        let vw = UIButton(type: .system)
        vw.setImage(UIImage(named: "next"), for: .normal)
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.tag = 1
        vw.addTarget(self, action: #selector(move), for: .touchUpInside)
        return vw
    }()
    
    var backBtn: UIButton = {
        let vw = UIButton(type: .system)
        vw.setImage(UIImage(named: "back"), for: .normal)
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.tag = 2
        vw.addTarget(self, action: #selector(move), for: .touchUpInside)
        return vw
    }()
    
    lazy var stack: UIStackView = {
        let vw = UIStackView(arrangedSubviews: [closeBtn, poster, title, slide])
        vw.axis = .vertical
        vw.distribution = .fillProportionally
        vw.spacing = 10
        return vw
    }()
    
    lazy var stackBtns: UIStackView = {
        let vw = UIStackView(arrangedSubviews: [backBtn, playBtn, forwardBtn])
        vw.axis = .horizontal
        vw.distribution = .fillEqually
        vw.spacing = 0
        return vw
    }()
    
    lazy var fullStackview: UIStackView = {
        let vw = UIStackView(arrangedSubviews: [stack, stackBtns])
        vw.axis = .vertical
        vw.spacing = 30
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    var miniPoster: UIImageView = {
        let vw = UIImageView()
        vw.contentMode = .scaleAspectFit
        vw.clipsToBounds = true
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    var miniTitle: UILabel = {
        let vw = UILabel()
        vw.numberOfLines = 0
        return vw
    }()
    
    var miniPlayBtn: UIButton = {
        let vw = UIButton(type: .system)
        vw.setImage(UIImage(named: "play"), for: .normal)
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        return vw
    }()
    
    lazy var miniStackview: UIStackView = {
        let vw = UIStackView(arrangedSubviews: [miniPoster, miniTitle, miniPlayBtn])
        vw.axis = .horizontal
        vw.spacing = 10
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    @objc func togglePlayerView(sender: UIButton) {
        let homePage = UIApplication.shared.keyWindow?.rootViewController as! HomeNavigationController
        homePage.togglePlayer()
    }
    
    @objc func handleSlide(sender: UISlider) {
        let percentage = sender.value
        if let duration = player.currentItem?.duration {
            let seconds = CMTimeGetSeconds(duration)
            let seekPoint = seconds * Float64(percentage)
            let point = CMTimeMakeWithSeconds(seekPoint, preferredTimescale: 1)
            player.seek(to: point)
        }
    }
    
    @objc func playPause() {
        if player.timeControlStatus == .playing {
            player.pause()
            playBtn.setImage(UIImage(named: "play"), for: .normal)
            miniPlayBtn.setImage(UIImage(named: "play"), for: .normal)
        }
        else {
            player.play()
            playBtn.setImage(UIImage(named: "pause"), for: .normal)
            miniPlayBtn.setImage(UIImage(named: "pause"), for: .normal)
        }
    }
    
    func playAudio(url: String) {
        let url = URL(string: url)
        player.replaceCurrentItem(with: AVPlayerItem(url: url!))
        player.automaticallyWaitsToMinimizeStalling = false
        playBtn.setImage(UIImage(named: "pause"), for: .normal)
        miniPlayBtn.setImage(UIImage(named: "pause"), for: .normal)
        player.play()
    }
    
    @objc func move(sender: UIButton) {
        let sec = CMTimeMake(value: 15, timescale: 1)
        var cmt: CMTime!
        if sender.tag == 1 {
            cmt = CMTimeAdd(player.currentTime(), sec)
        } else {
            cmt = CMTimeSubtract(player.currentTime(), sec)
        }
        player.seek(to: cmt)
    }

}
