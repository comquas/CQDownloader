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
    case fileExist
}

class CQDownloader: NSObject {
    
    var backgroundCompletionHandler: (() -> Void)?
    
    private let fileManager = FileManager.default
    private let context = CQDownloaderContext.shared
    private var session: URLSession!
    private var tasks:[URL: URLSessionDownloadTask] = [:]
    
    var downloadProgress: ((_ download: CQDownloadItem) -> Void)?
    var downloadFinish: ((_ result: DataRequestResult<URL>) -> Void)?
    
//    func CQDownloadProgress(downloadItem: CQDownloadItem)
//    //    func CQdownloadFinish(result: DataRequestResult<URL>)
//    var delegate: CQDownloaderDelegate?
    
    // MARK: - Singleton
    
    
     let group = DispatchGroup()
    
    
    static let shared = CQDownloader()
    
    // MARK: - Init
    
    private init(identifier:String? = nil) {
        super.init()
        let backgroundIdentifier = identifier ?? "background.download.session"
        let configuration = URLSessionConfiguration.background(withIdentifier: backgroundIdentifier)
//        configuration.httpMaximumConnectionsPerHost = 1
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        context.loadAllToMemory()
    
        session.getTasksWithCompletionHandler { (sessionTask:[URLSessionDataTask], uploadTask:[URLSessionUploadTask], downloadTask:[URLSessionDownloadTask]) in
            
           
            
            
            for currentTask in downloadTask {
                if let loadingURL = currentTask.originalRequest?.url {
                    self.tasks[loadingURL] = currentTask
                    
                }
            }
            
            
        }
        
        
        
        
    }
    
    func pauseAll() {
        let urls = self.getAllUrls()
        
        for url in urls {
            if let dlURL = URL(string: url) {
               
                    self.pause(remoteURL: dlURL, sync: true)
            }
        }
        
      
    }
    
    // MARK: - Document Path
    func documentURL(fileName: String) -> URL {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        let cacheURL = URL(fileURLWithPath: path)
        return cacheURL.appendingPathComponent(fileName)
    }
    
    // MARK: - Get Download Item
    
    func downloadItem(remoteURL: URL) -> CQDownloadItem? {
        return context.loadDownloadItem(withURL: remoteURL)
    }
    
    // MARK: - Download
    
    
    
    func download(remoteURL: URL, filePathURL: URL, data: [String:String]?,overwrite: Bool = true, onProgressHandler:  ProgressDownloadingHandler?, completionHandler: ForegroundDownloadCompletionHandler?) {
        
        if let downloadItem = context.loadDownloadItem(withURL: remoteURL) {
            print("Already downloading: \(remoteURL)")
            downloadItem.foregroundCompletionHandler = completionHandler
            downloadItem.progressDownloadHandler = onProgressHandler
            
        } else {
            print("Scheduling to download: \(remoteURL)")
            
            if fileManager.fileExists(atPath: filePathURL.path) {
            
                    if overwrite {
                        do {
                        try fileManager.removeItem(at: filePathURL)
                        }
                        catch {
                            print(error)
                        }
                    }
                    else {
                        completionHandler?(.failure(CQError.fileExist,remoteURL))
                        return
                    }
            }
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
        
        if error == nil {
            return
        }
        guard let originalRequestURL = task.originalRequest?.url, let downloadItem = context.loadDownloadItem(withURL: originalRequestURL) else {
            return
        }
        
        
        context.saveDownloadItem(downloadItem)
        
        if let err = error as NSError? {
            if err.code == -999 {
                downloadItem.status = .Pause
                downloadItem.foregroundCompletionHandler?(.failure(CQError.cancel,downloadItem.remoteURL))
                
                if let callback = self.downloadFinish {
                    callback(.failure(CQError.cancel,downloadItem.remoteURL))
                }
                return
            }
        }
        downloadItem.status = .Fail
        downloadItem.foregroundCompletionHandler?(.failure(CQError.unknown,downloadItem.remoteURL))
        
        if let callback = self.downloadFinish {
            callback(.failure(CQError.unknown,downloadItem.remoteURL))
        }
        
        
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
                
                
                if let callback = self.downloadFinish {
                    callback(.success(downloadItem.remoteURL))
                }
           
            
        } catch {
            print(error)
            downloadItem.status = .Fail
            context.saveDownloadItem(downloadItem)
            downloadItem.foregroundCompletionHandler?(.failure(CQError.invalidData,downloadItem.remoteURL))
             
            if let callback = self.downloadFinish {
                callback(.failure(CQError.invalidData,downloadItem.remoteURL))
            }
        }
        
    }
    
    func updateTasks(downloadTask: URLSessionDownloadTask) {
        
        var requestURL = downloadTask.originalRequest?.url
        if requestURL == nil {
            requestURL = downloadTask.currentRequest?.url
        }
        
        if let url = requestURL {
            if CQDownloader.shared.tasks[url] == nil {
                CQDownloader.shared.tasks[url] = downloadTask
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        
        updateTasks(downloadTask: downloadTask)
        
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
        
        if let callback = self.downloadProgress {
            callback(downloadItem)
        }
        
        
    }
    
    
}

// MARK: - Funcation
extension CQDownloader {
    
    
    func getAllUrls() -> [String] {
        return self.context.getAllUrls()
    }
    
    func pause(remoteURL: URL,sync: Bool = false) {
        
        guard let downloadItem = context.loadDownloadItem(withURL: remoteURL) else {
            return
        }
        
        if downloadItem.status == .Progress {
            
            guard let downloadItem = context.loadDownloadItem(withURL: remoteURL) else {
                return
            }
            guard let downloadSession = self.tasks[remoteURL] else {
                
                return
            }
            
            if(sync) {
                group.enter()
            }
            
            downloadSession.cancel { (data:Data?) in
                
                let timestamp = "\(NSDate().timeIntervalSince1970)"
                
                let writeURL = self.documentURL(fileName: "cqresume_\(timestamp)")
                
                if downloadItem.resumeDataPath != ""  {
                    return
                }
                do {
                    try data?.write(to: writeURL)
                    downloadItem.resumeDataPath = writeURL.path
                    downloadItem.status = .Pause
                    self.context.saveDownloadItem(downloadItem)
                    self.tasks.removeValue(forKey: remoteURL)
                    
                }
                catch {
                    print(error)
                }
                
                if(sync) {
                    self.group.leave()
                }
                
            }
            
            if(sync) {
                group.wait()
            }
            
        }
    }
    
    func resume(remoteURL: URL) {
        
        guard let downloadItem = context.loadDownloadItem(withURL: remoteURL) else {
            return
        }
        
        
        let url = URL(fileURLWithPath:downloadItem.resumeDataPath)
        
        do {
            let data = try Data(contentsOf: url)
            try FileManager.default.removeItem(at: url)
            downloadItem.resumeDataPath = ""
            downloadItem.status = .Progress
            self.context.saveDownloadItem(downloadItem)
            
            let task = session.downloadTask(withResumeData: data)
            
            self.tasks[remoteURL] = task
            task.resume()
        }
        catch {
            print(error)
        }
    }
    func toggleDownloadAction(remoteURL: URL) {
        
        guard let downloadItem = context.loadDownloadItem(withURL: remoteURL) else {
            return
        }
        
        if downloadItem.status == .Progress {
            self.pause(remoteURL: remoteURL)
        }
        else if downloadItem.status == .Pause {
            self.resume(remoteURL: remoteURL)
        }
    }
    
    func delete(remoteURL: URL) {
        guard let downloadItem = context.loadDownloadItem(withURL: remoteURL) else {
            return
        }
        context.deleteDownloadItem(downloadItem)
        let task = self.tasks[remoteURL]
        task?.cancel()
        self.tasks.removeValue(forKey: remoteURL)
        do {
            try fileManager.removeItem(at: remoteURL)
        } catch {
            print(error)
        }
    }
}
