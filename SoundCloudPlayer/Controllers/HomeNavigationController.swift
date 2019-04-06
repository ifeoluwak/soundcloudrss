//
//  HomeController.swift
//  SoundCloudPlayer
//
//  Created by Bambooks on 04/04/2019.
//  Copyright © 2019 ifeoluwa. All rights reserved.
//

import UIKit

class HomeNavigationController: UINavigationController {
    
    let playerView = PlayerView.createPlayer()
    
     var maximise: NSLayoutConstraint!
     var minimise: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(playerView)

        setupPlayerView()
        
    }
    
    fileprivate func setupPlayerView() {
        maximise = playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height)
        minimise = playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        
        maximise.isActive = true
        playerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        playerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func showPlayer(song: Song, poster: UIImage, indexOfSong: Int) {
        playerView.song = song
        playerView.posterImg = poster
        playerView.indexOfSong = indexOfSong
        
        playerView.showFullPlayer()
        
        maximise.isActive = true
        maximise.constant = 0
        minimise.isActive = false
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func togglePlayer() {
        if maximise.isActive == true {
            maximise.isActive = false
            minimise.isActive = true
            playerView.showMiniPlayer()
        } else {
            playerView.showFullPlayer()
            maximise.isActive = true
            maximise.constant = 0
            minimise.isActive = false
        }
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }


}
