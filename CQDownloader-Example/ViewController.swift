//
//  ViewController.swift
//  CQDownloader-Example
//
//  Created by Htain Lin Shwe on 1/11/18.
//  Copyright © 2018 COMQUAS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let downloader = CQDownloader.shared
    @IBOutlet var lbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    @IBAction func addToDownload() {
        
        let number = Int.random(in: 1 ..< 999)
        let downloadURL = URL(string:"https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_30mb.mp4?image=\(number)")!
        
        self.performSegue(withIdentifier: "gotoDownload", sender: downloadURL)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoDownload" {
            if let vc = segue.destination as? TableViewController {
                if let url = sender as? URL {
                    vc.newdownloadURL = url
                }
            }
        }
    }
    
    

    


}

