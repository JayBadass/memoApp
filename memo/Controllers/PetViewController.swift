//
//  PetViewController.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/29.
//

import UIKit
import Alamofire

class PetViewController: UIViewController {
    
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var petImage: UIImageView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCatImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func fetchCatImage() {
        let urlString = "https://api.thecatapi.com/v1/images/search"
        guard URL(string: urlString) != nil else { return }
        
        self.petImage.image = UIImage(named: "placeholder")
        
        AF.request(urlString).responseDecodable(of: [CatImage].self) {
            (response) in switch response.result {
            case .success(let petImage):
                if let firstImage = petImage.first {
                    DispatchQueue.main.async {
                        self.petImage.frame.size = CGSize(width: firstImage.width, height: firstImage.height)
                    }
                    self.loadImage(from: firstImage.url)
                }
            case .failure(let error):
                print("Error fetching data:", error)
            }
        }
    }
    
    func loadImage(from urlString: String) {
        AF.request(urlString).responseData { (response) in
            switch response.result {
            case .success(let data):
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.petImage.image = image
                }
            case .failure(let error):
                print("Error fetching image:", error)
            }
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        fetchCatImage()
    }
}
