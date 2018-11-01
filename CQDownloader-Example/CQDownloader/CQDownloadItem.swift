//
//  DownloadItem.swift
//  CQDownloader-Example
//
//  Created by Htain Lin Shwe on 1/11/18.
//  Copyright © 2018 COMQUAS. All rights reserved.
//

import Foundation

enum DataRequestResult<T> {
    case success(T)
    case failure(Error)
}

typealias ProgressDownloadingHandler = ((_ item: CQDownloadItem ) -> Void)
typealias ForegroundDownloadCompletionHandler = ((_ result: DataRequestResult<URL>) -> Void)

enum CQDownloadStatus : Int, Codable {
    case Done = 1
    case Pause = 2
    case Fail = 3
    case Progress = 4
    case None = 0
}
class CQDownloadItem: Codable {
    
    var data: [String:String] = [:]
    let remoteURL: URL
    let filePathURL: URL
    
    var status: CQDownloadStatus = CQDownloadStatus.None
    var totalFileSize: Double = 0.0
    var currentFileSize: Double = 0.0
    var progress: Float = 0.0
    var resumeData: String = ""
    
    var foregroundCompletionHandler: ForegroundDownloadCompletionHandler?
    var progressDownloadHandler: ProgressDownloadingHandler?
    
    private enum CodingKeys: String, CodingKey {
        case remoteURL
        case filePathURL
        case data
        case status
        case totalFileSize
        case currentFileSize
        case progress
    }
    
    
    // MARK: - Init
    
    
    init(remoteURL: URL, filePathURL: URL,data:[String:String]? = nil) {
        self.remoteURL = remoteURL
        self.filePathURL = filePathURL
        
        if let d = data {
            self.data = d
        }
    }
}
