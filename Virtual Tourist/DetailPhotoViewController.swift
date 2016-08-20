//
//  DetailPhotoViewController.swift
//  Virtual Tourist
//
//  Created by Mike Weng on 1/29/16.
//  Copyright © 2016 Weng. All rights reserved.
//

import Foundation
import UIKit
class DetailPhotoViewController: UIViewController {
    var photo: Photo!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = photo.image
    }
}