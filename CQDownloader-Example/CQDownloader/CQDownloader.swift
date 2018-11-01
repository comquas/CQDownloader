//
//  BackgroundDownloader.swift
//  CQDownloader-Example
//
//  Created by Htain Lin Shwe on 1/11/18.
//  Copyright © 2018 COMQUAS. All rights reserved.
//

import Foundation
import UIKit

enum CQError: Error {
    case unknown
    case cancel
    case missingData
    case serialization
    case invalidData
}

class CQDownloader: NSObject {
    
    var backgroundCompletionHandler: (() -> Void)?
    
    private let fileManager = FileManager.default
    private let context = CQDownloaderContext()
    private var session: URLSession!
    private var tasks:[URL: URLSessionDownloadTask] = [:]
    
    // MARK: - Singleton
    
    static let shared = CQDownloader()
    
    // MARK: - Init
    
    private init(identifier:String? = nil) {
        super.init()
        let backgroundIdentifier = identifier ?? "background.download.session"
        let configuration = URLSessionConfiguration.background(withIdentifier: backgroundIdentifier)
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        session.getTasksWithCompletionHandler { (sessionTask:[URLSessionDataTask], uploadTask:[URLSessionUploadTask], downloadTask:[URLSessionDownloadTask]) in
            for currentTask in downloadTask {
                if let loadingURL = currentTask.originalRequest?.url {
                    self.tasks[loadingURL] = currentTask
                }
            }
        }
    }
    
    // MARK: - Document Path
    func documentURL(fileName: String) -> URL {
        
        let cacheURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last!
        return cacheURL.appendingPathComponent(fileName)
    }
    
    // MARK: - Get Download Item
    
    func downloadItem(remoteURL: URL) -> CQDownloadItem? {
        return context.loadDownloadItem(withURL: remoteURL)
    }
    
    func downloadTask(remoteURL: URL) -> URLSessionDownloadTask {
        return session.downloadTask(with: remoteURL)
    }
    
    // MARK: - Funcation
    func toggleDownloadAction(remoteURL: URL) {
        guard let downloadItem = context.loadDownloadItem(withURL: remoteURL) else {
            return
        }
      
        
        if downloadItem.status == .Progress {
            
            guard let downloadSession = self.tasks[remoteURL] else {
                return
            }
            
            downloadSession.cancel { (data:Data?) in
                guard let d = data?.base64EncodedString() else {
                    return
                }
                downloadItem.resumeData = d
                downloadItem.status = .Pause
                self.context.saveDownloadItem(downloadItem)
                self.tasks.removeValue(forKey: remoteURL)
            }
        }
        else if downloadItem.status == .Pause {
            guard let data = Data(base64Encoded: downloadItem.resumeData) else {
                return
            }
            
            downloadItem.resumeData = ""
            downloadItem.status = .Progress
            self.context.saveDownloadItem(downloadItem)
            
            let task = session.downloadTask(withResumeData: data)
            
            self.tasks[remoteURL] = task
            task.resume()
        }
    }
    
    // MARK: - Download
    
    func download(remoteURL: URL, filePathURL: URL, data: [String:String]?, onProgressHandler: @escaping ProgressDownloadingHandler, completionHandler: @escaping ForegroundDownloadCompletionHandler) {
        if let downloadItem = context.loadDownloadItem(withURL: remoteURL) {
            print("Already downloading: \(remoteURL)")
            downloadItem.foregroundCompletionHandler = completionHandler
            downloadItem.progressDownloadHandler = onProgressHandler
           
        } else {
            print("Scheduling to download: \(remoteURL)")
            
            let downloadItem = CQDownloadItem(remoteURL: remoteURL, filePathURL: filePathURL,data: data)
            downloadItem.foregroundCompletionHandler = completionHandler
            downloadItem.progressDownloadHandler = onProgressHandler
            downloadItem.status = .Progress
            context.saveDownloadItem(downloadItem)
            
            let task = session.downloadTask(with: remoteURL)
            
            self.tasks[remoteURL] = task
            task.resume()
        }
    }
}

// MARK: - URLSessionDelegate

extension CQDownloader: URLSessionDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
}

// MARK: - URLSessionDownloadDelegate

extension CQDownloader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let originalRequestURL = task.originalRequest?.url, let downloadItem = context.loadDownloadItem(withURL: originalRequestURL) else {
            return
        }
        
        
        context.saveDownloadItem(downloadItem)
        
        if let err = error as NSError? {
            if err.code == -999 {
                downloadItem.foregroundCompletionHandler?(.failure(CQError.cancel))
                downloadItem.status = .Pause
                return
            }
        }
        downloadItem.status = .Fail
        downloadItem.foregroundCompletionHandler?(.failure(CQError.unknown))
            
        
    }
    
    private func getDownloadItemFromDownloadTask(downloadTask: URLSessionDownloadTask) -> CQDownloadItem? {
        
        var requestURL = downloadTask.originalRequest?.url
        if requestURL == nil {
            requestURL = downloadTask.currentRequest?.url
        }
        
        guard let requestingURL = requestURL, let downloadItem = context.loadDownloadItem(withURL: requestingURL) else {
            return nil
        }
        return downloadItem
        
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let downloadItem = self.getDownloadItemFromDownloadTask(downloadTask: downloadTask) else {
            return
        }
        print("Downloaded: \(downloadItem.remoteURL)")
        
        
        
        do {
            try fileManager.moveItem(at: location, to: downloadItem.filePathURL)
            downloadItem.status = .Done
            context.saveDownloadItem(downloadItem)
            downloadItem.foregroundCompletionHandler?(.success(downloadItem.filePathURL))
        } catch {
            
            downloadItem.status = .Fail
            context.saveDownloadItem(downloadItem)
            downloadItem.foregroundCompletionHandler?(.failure(CQError.invalidData))
        }
        
        //context.deleteDownloadItem(downloadItem)
   
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let downloadItem = self.getDownloadItemFromDownloadTask(downloadTask: downloadTask) else {
            return
        }
        
        let receivedBytesCount = Double(downloadTask.countOfBytesReceived)
        let totalBytesCount = Double(downloadTask.countOfBytesExpectedToReceive)
        let progress = Float(receivedBytesCount / totalBytesCount)
        
        downloadItem.currentFileSize = receivedBytesCount
        downloadItem.totalFileSize = totalBytesCount
        downloadItem.progress = progress
        
        downloadItem.status = .Progress
        context.saveDownloadItem(downloadItem)
        
        downloadItem.progressDownloadHandler?(downloadItem)
        
    }
    
    
}

