//
//  CQDownloaderCell.swift
//  CQDownloader-Example
//
//  Created by Htain Lin Shwe on 1/11/18.
//  Copyright © 2018 COMQUAS. All rights reserved.
//

import UIKit

public struct Units {
    
    public let bytes: Int64
    
    public var kilobytes: Double {
        return Double(bytes) / 1_024
    }
    
    public var megabytes: Double {
        return kilobytes / 1_024
    }
    
    public var gigabytes: Double {
        return megabytes / 1_024
    }
    
    public init(bytes: Int64) {
        self.bytes = bytes
    }
    
    public func getReadableUnit() -> String {
        
        switch bytes {
        case 0..<1_024:
            return "\(bytes) bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) kb"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) mb"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.2f", gigabytes)) gb"
        default:
            return "\(bytes) bytes"
        }
    }
}



class CQDownloaderCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    var remoteURL: URL?
    let downloader = CQDownloader.shared
    
    var clickonDelete: ((_ cell: CQDownloaderCell,_ remoteURL: URL?) -> Void)?
    
    func updateCell() {
        if let url = remoteURL , let downloadItem = CQDownloader.shared.downloadItem(remoteURL: url) {
            titleLabel.text = downloadItem.data["Title"]
            
            let currentSize = Units(bytes: Int64(downloadItem.currentFileSize)).getReadableUnit()
            let totalSize = Units(bytes: Int64(downloadItem.totalFileSize)).getReadableUnit()
            
            if (downloadItem.totalFileSize == -1) {
                progressLabel.text = "\(currentSize) / Unkowned"
            }
            else {
                progressLabel.text = "\(currentSize) / \(totalSize)"
            }
            
           
            let percentage = Int(downloadItem.progress * 100)
            
            
            
            if (downloadItem.totalFileSize == -1) {
                percentageLabel.text = "\(currentSize)"
            }
            else {
                percentageLabel.text = "\(percentage) %"
            }
            
            var p = downloadItem.progress
            if p > 1 {
                p = 0
            }
            progressBar.setProgress(p, animated: true)
            
            pauseButton.isEnabled = true
             pauseButton.isHidden = false
            switch downloadItem.status {
            case .Done:
                pauseButton.isHidden = true
            case .Fail:
                pauseButton.setTitle("Failed", for: .normal)
                pauseButton.isEnabled = false
            case .Pause:
                pauseButton.setTitle("Resume", for: .normal)
            case .Progress:
                pauseButton.setTitle("Pause", for: .normal)
            case .None:
                pauseButton.setTitle("Waiting", for: .normal)
                pauseButton.isEnabled = false
            }
            
        }
        else {
            titleLabel.text = ""
            progressLabel.text = ""
            percentageLabel.text = ""
            progressBar.setProgress(0, animated: true)
        }
    }
    
    @IBAction func pauseResume() {
        if let url = remoteURL {
            downloader.toggleDownloadAction(remoteURL: url)
            self.updateCell()
        }
    }
    
    @IBAction func delete() {
        
        if let callback = self.clickonDelete {
            callback(self,self.remoteURL)
        }
    }
}
