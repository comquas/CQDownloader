//
//  BackgroundDownloaderContext.swift
//  CQDownloader-Example
//
//  Created by Htain Lin Shwe on 1/11/18.
//  Copyright © 2018 COMQUAS. All rights reserved.
//

import Foundation

class CQDownloaderContext {
    
    private var inMemoryDownloadItems: [URL: CQDownloadItem] = [:]
    private let userDefaults = UserDefaults.standard
    private let downloadListKey = "CQDOwnloadList"
    // MARK: - Load
    
    static let shared = CQDownloaderContext()
    
    func loadDownloadItem(withURL url: URL) -> CQDownloadItem? {
        
        
        if let downloadItem = inMemoryDownloadItems[url] {
            return downloadItem
        } else if let downloadItem = loadDownloadItemFromStorage(withURL: url) {
            
            inMemoryDownloadItems[downloadItem.remoteURL] = downloadItem
            
            return downloadItem
        }
        
        return nil
    }
    
    func getAllProgressItems() -> [URL:CQDownloadItem]? {
        
        let items =  inMemoryDownloadItems.filter { (key: URL, value: CQDownloadItem) -> Bool in
            if value.status == .Progress {
                return true
            }
            return false
        }
        return items
        
    }
    
    
    private func loadDownloadItemFromStorage(withURL url: URL) -> CQDownloadItem? {
        guard let encodedData = userDefaults.object(forKey: url.absoluteString) as? Data else {
            return nil
        }
        
        let downloadItem = try? JSONDecoder().decode(CQDownloadItem.self, from: encodedData)
        return downloadItem
    }
    
    // MARK: - Load Items
    func getAllUrls() -> [String] {
        
        if let downloadList = userDefaults.array(forKey: self.downloadListKey) as? [String] {
            return downloadList
        }
        return []
    }
    
    func loadAllToMemory() {
        if let downloadList = userDefaults.array(forKey: self.downloadListKey) as? [String] {
            for path in downloadList {
                if let url = URL(string: path) {
                    _ = loadDownloadItem(withURL: url)
                }
            }
        }
    }
    
    // MARK: - Save
    
    func saveDownloadItem(_ downloadItem: CQDownloadItem) {
        
        
        if(inMemoryDownloadItems[downloadItem.remoteURL] != nil) {
            
            inMemoryDownloadItems[downloadItem.remoteURL]?.data = downloadItem.data
            inMemoryDownloadItems[downloadItem.remoteURL]?.status = downloadItem.status
            inMemoryDownloadItems[downloadItem.remoteURL]?.totalFileSize = downloadItem.totalFileSize
            inMemoryDownloadItems[downloadItem.remoteURL]?.currentFileSize = downloadItem.currentFileSize
            inMemoryDownloadItems[downloadItem.remoteURL]?.progress = downloadItem.progress
            inMemoryDownloadItems[downloadItem.remoteURL]?.resumeDataPath = downloadItem.resumeDataPath
            
            
            
        }
        else {
            inMemoryDownloadItems[downloadItem.remoteURL] = downloadItem
        }
        
        let encodedData = try? JSONEncoder().encode(downloadItem)
        
        userDefaults.set(encodedData, forKey: downloadItem.remoteURL.absoluteString)
        
        //check and save in the download list
        if var downloadList = userDefaults.array(forKey: self.downloadListKey) as? [String] {
            
            //need to search in list first
            if downloadList.firstIndex(of: downloadItem.remoteURL.absoluteString) == nil {
                downloadList.append(downloadItem.remoteURL.absoluteString)
            }
            userDefaults.set(downloadList, forKey: self.downloadListKey)
        }
        else {
            userDefaults.set([downloadItem.remoteURL.absoluteString], forKey: self.downloadListKey)
        }
        
        userDefaults.synchronize()
    }
    
    // MARK: - Delete
    
    func deleteDownloadItem(_ downloadItem: CQDownloadItem) {
        inMemoryDownloadItems[downloadItem.remoteURL] = nil
        userDefaults.removeObject(forKey: downloadItem.remoteURL.absoluteString)
        
        //remove it from download list
        if let downloadList = userDefaults.array(forKey: self.downloadListKey) as? [String] {
            let updatedDOwnloadList = downloadList.filter { $0 != downloadItem.remoteURL.absoluteString }
            userDefaults.set(updatedDOwnloadList, forKey: self.downloadListKey)
        }
        
        userDefaults.synchronize()
    }
}
