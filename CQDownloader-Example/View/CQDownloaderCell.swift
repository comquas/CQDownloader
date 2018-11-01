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
    var remoteURL: URL?
    
    func updateCell() {
        if let url = remoteURL , let downloadItem = CQDownloader.shared.downloadItem(remoteURL: url) {
            titleLabel.text = downloadItem.data["Title"]
            
            let currentSize = Units(bytes: Int64(downloadItem.currentFileSize)).getReadableUnit()
            let totalSize = Units(bytes: Int64(downloadItem.totalFileSize)).getReadableUnit()
            
            
            progressLabel.text = "\(currentSize) / \(totalSize)"
            var percentage = Int(downloadItem.progress * 100)
            percentageLabel.text = "\(percentage) %"
            
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
