//
//  TableViewController.swift
//  CQDownloader-Example
//
//  Created by Htain Lin Shwe on 1/11/18.
//  Copyright © 2018 COMQUAS. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var dataSource: [String] = []
    let downloader = CQDownloader.shared
    var newdownloadURL: URL?
    var cells:Dictionary<URL,CQDownloaderCell> = Dictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = downloader.getAllUrls()
        
        self.downloader.downloadProgress  = { (downloadItem: CQDownloadItem) -> Void in
            self.updateCell(remoteURL: downloadItem.remoteURL)
        }
        
        if let dl = newdownloadURL {
            self.downloadFile(remoteURL: dl)
        }
        
    }
    
    func downloadFile(remoteURL: URL) {
        
        let number = remoteURL.absoluteString.components(separatedBy: "?image=").last!
        let filepath = downloader.documentURL(fileName: "\(number).mp4")
        
        self.downloader.download(remoteURL: remoteURL, filePathURL: filepath, data: ["Title": number], onProgressHandler: { (downloadItem:CQDownloadItem) in
            
        }) { (result:DataRequestResult<URL>) in
            
        }
        newdownloadURL = nil
        self.dataSource = downloader.getAllUrls()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataSource.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! CQDownloaderCell
        
        cell.remoteURL = URL(string:self.dataSource[indexPath.row])
        cell.clickonDelete = {(cell: CQDownloaderCell,remoteURL: URL?) -> Void in
            
            if let url = remoteURL {
                self.cells[url] = nil
            }
            
            if let url = remoteURL {
                if let row = self.dataSource.firstIndex(of: url.absoluteString) {
                    CQDownloader.shared.delete(remoteURL: url)
                    self.tableView.beginUpdates()
                    self.dataSource.remove(at: row)
                    self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                }
            }
        }
        cell.updateCell()
        
        if let remoteURL = cell.remoteURL {
            cells[remoteURL] = cell
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
      
        guard let url = URL(string:self.dataSource[indexPath.row]),
            let downloadItem = CQDownloader.shared.downloadItem(remoteURL: url) else {
                return
        }
        
       
        
        if downloadItem.status == .Done {
            let alert = UIAlertController(title: "Progress", message: "DONE \(downloadItem.progress)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
            self.performSegue(withIdentifier: "showImage", sender: downloadItem.filePathURL.path)
        }
        else {
            let alert = UIAlertController(title: "Progress", message: "\(downloadItem.status)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage" {
            if let vc = segue.destination as? ResultImageViewController {
                if let path = sender as? String {
                    vc.imagePath = path
                }
            }
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}





extension TableViewController  {
    
    private func updateData(remoteURL: URL) {
        DispatchQueue.main.async {
            
            //if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? CQDownloaderCell {
            if let cell = self.cells[remoteURL] {
                cell.updateCell()
            }
            
        }
    }
    
    private func updateCell(remoteURL: URL) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                return
            }
            self.updateData(remoteURL: remoteURL)
        }
        
    }
    func CQDownloadProgress(downloadItem: CQDownloadItem) {
        
    }
    func CQdownloadFinish(result: DataRequestResult<URL>) {
        switch result {
        case .success(let url):
            
            updateCell(remoteURL: url)
            
        case .failure(let error,let url):
            print(error)
            updateCell(remoteURL: url)
        }
        
    }
    
    
}
