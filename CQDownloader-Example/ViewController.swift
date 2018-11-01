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
        
        let number = Int.random(in: 0 ..< 999)
        let downloadURL = URL(string:"http://ipv4.download.thinkbroadband.com/512MB.zip?id=\(number)")!
        
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
    
    
//    @IBAction func addToDownload() {
//
//
//        let data = ["Title" : "\(number)"]
//        downloader.download(remoteURL: downloadURL, filePathURL: downloader.documentURL(fileName: "\(number).zip"), data: data, onProgressHandler: { (downloadItem: CQDownloadItem) in
//            print(downloadItem.progress)
//        }, completionHandler: { (result:DataRequestResult<URL>) in
//            switch result {
//            case .success(let url):
//                    print("Finish \(url)")
//            case .failure(let error):
//                print("CANCEL OR FAIL")
//                }
//        })
//
//    }
//
//    @IBAction func pauseAndResume() {
//        downloader.toggleDownloadAction(remoteURL: downloadURL)
//    }
    
    


}

