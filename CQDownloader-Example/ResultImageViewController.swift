//
//  ResultImageViewController.swift
//  CQDownloader-Example
//
//  Created by Htain Lin Shwe on 1/11/18.
//  Copyright © 2018 COMQUAS. All rights reserved.
//

import UIKit
import AVKit

class ResultImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imagePath: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    @IBAction func open() {
        
        let videoURL = URL(fileURLWithPath: imagePath)
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
        
    }
}
