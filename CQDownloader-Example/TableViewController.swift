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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = downloader.getAllUrls()
        
        self.downloader.delegate = self
        
        if let dl = newdownloadURL {
            self.downloadFile(remoteURL: dl)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func downloadFile(remoteURL: URL) {
        
        let number = remoteURL.absoluteString.components(separatedBy: "?id=").last!
        let filepath = downloader.documentURL(fileName: "\(number).zip")
        
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
        cell.updateCell()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
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

extension TableViewController: CQDownloaderDelegate {
    
    private func updateCell(remoteURL: URL) {
        if let row = self.dataSource.firstIndex(of: remoteURL.absoluteString) {
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? CQDownloaderCell {
                    cell.remoteURL = remoteURL
                    cell.updateCell()
                }
            }
            
        }
    }
    func CQDownloadProgress(downloadItem: CQDownloadItem) {
        updateCell(remoteURL: downloadItem.remoteURL)
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
