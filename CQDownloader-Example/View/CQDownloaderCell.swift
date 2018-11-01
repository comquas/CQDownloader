//
//  CQDownloaderCell.swift
//  CQDownloader-Example
//
//  Created by Htain Lin Shwe on 1/11/18.
//  Copyright © 2018 COMQUAS. All rights reserved.
//

import UIKit

class CQDownloaderCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    var remoteURL: URL?
    
    func updateCell() {
        if let url = remoteURL , let downloadItem = CQDownloader.shared.downloadItem(remoteURL: url) {
            titleLabel.text = downloadItem.data["Title"]
            progressLabel.text = "\(downloadItem.currentFileSize) / \(downloadItem.totalFileSize) Bytes"
            percentageLabel.text = "\(downloadItem.progress * 100) %"
            
            var p = downloadItem.progress
            if p > 1 {
                p = 0
            }
            progressBar.setProgress(p, animated: true)
        }
        else {
            titleLabel.text = ""
            progressLabel.text = ""
            percentageLabel.text = ""
            progressBar.setProgress(0, animated: true)
        }
    }
    
    @IBAction func pauseResume() {
        
    }
    
    @IBAction func delete() {
        
    }
}
