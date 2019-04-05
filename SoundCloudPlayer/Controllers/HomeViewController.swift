//
//  ViewController.swift
//  SoundCloudPlayer
//
//  Created by Bambooks on 03/04/2019.
//  Copyright © 2019 ifeoluwa. All rights reserved.
//

import UIKit
import FeedKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
    }

    @IBAction func goToPodcast(_ sender: Any) {
        navigationController?.pushViewController(SongListController(), animated: true)
    }
    
}
