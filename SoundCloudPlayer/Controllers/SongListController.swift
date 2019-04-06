//
//  HomeViewController.swift
//  SoundCloudPlayer
//
//  Created by Bambooks on 04/04/2019.
//  Copyright © 2019 ifeoluwa. All rights reserved.
//

import UIKit
import FeedKit

var songList = [Song]()
class SongListController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableV: UITableView =  {
        let vw = UITableView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        
        return vw
    }()
    
    let poster: UIImageView =  {
        let vw = UIImageView()
        vw.contentMode = .scaleAspectFill
        vw.clipsToBounds = true
        vw.translatesAutoresizingMaskIntoConstraints = false
        
        return vw
    }()
    
    var songs = [Song]() {
        didSet {
            tableV.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableV.delegate = self
        tableV.dataSource = self
        tableV.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(tableV)
        view.addSubview(poster)
        setupLayout()
        fetchRssFeed()
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            poster.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            poster.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            poster.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            poster.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
            tableV.topAnchor.constraint(equalTo: poster.bottomAnchor),
            tableV.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableV.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableV.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
        ])
    }
    
    func fetchRssFeed() {
        let feedURL = URL(string: RSS_URL)!
        let parser = FeedParser(URL: feedURL)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { [weak self] (result) in
            if let _ = result.error {
                return
            }
            
            guard let feed = result.rssFeed else { return }
            var songs = [Song]()
            if let posterImage = feed.iTunes?.iTunesImage?.attributes?.href {
                do {
                    let url = URL(string: posterImage)
                    let data = try Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        self?.poster.image = UIImage(data: data)
                    }
                }
                catch{
                    print(error)
                }
            }

            feed.items?.forEach({ (RSSFeedItem) in
                let title = RSSFeedItem.title
                let media = RSSFeedItem.enclosure?.attributes?.url
                let image = RSSFeedItem.iTunes?.iTunesImage?.attributes?.href
                let item = Song(title: title, media: media, image: image)
                songs.append(item)
            })
            DispatchQueue.main.async {
                self?.songs = songs
                songList = songs
            }
        }
    }
    
    func openSongPlayer(song: Song, indexOfSong: Int) {
        let homePage = UIApplication.shared.keyWindow?.rootViewController as! HomeNavigationController
        homePage.showPlayer(song: song, poster: poster.image!, indexOfSong: indexOfSong)
    }
}

extension SongListController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableV.dequeueReusableCell(withIdentifier: "cell")
        let song = songs[indexPath.row]
        cell?.textLabel?.text = song.title
        cell?.imageView?.image = UIImage(named: "70776")
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = songs[indexPath.row]
        openSongPlayer(song: song, indexOfSong: indexPath.row)
    }
}
