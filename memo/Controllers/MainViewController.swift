//
//  ViewController.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/02.
//

import UIKit
import Kingfisher

class MainViewController: UIViewController{
    
    @IBOutlet weak var mainImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageURL = "https://spartacodingclub.kr/css/images/scc-og.jpg"
        let url = URL(string: imageURL)
        mainImage.kf.setImage(with: url)
    }
}


