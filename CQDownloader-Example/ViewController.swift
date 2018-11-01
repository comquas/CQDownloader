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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func addToDownload() {
        
        let number = Int.random(in: 1 ..< 999)
        let downloadURL = URL(string:"https://picsum.photos/800/800/?image=\(number)")!
        
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

