//
//  ResultImageViewController.swift
//  CQDownloader-Example
//
//  Created by Htain Lin Shwe on 1/11/18.
//  Copyright © 2018 COMQUAS. All rights reserved.
//

import UIKit
class ResultImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imagePath: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(contentsOfFile: imagePath)
    }
}
