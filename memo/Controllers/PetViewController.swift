//
//  PetViewController.swift
//  memo
//
//  Created by Jongbum Lee on 2023/08/29.
//

import UIKit

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
        guard let url = URL(string: urlString) else { return }
        
        self.petImage.image = UIImage(named: "placeholder")
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                print("Error fetching data:", error ?? "")
                return
            }
            
            do {
                let catImages = try JSONDecoder().decode([CatImage].self, from: data)
                if let firstImage = catImages.first {
                    DispatchQueue.main.async {
                        self.petImage.frame.size = CGSize(width: firstImage.width, height: firstImage.height)
                    }
                    self.loadImage(from: firstImage.url)
                }
            } catch {
                print("Error decoding JSON:", error)
            }
        }.resume()
    }
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                print("Error fetching image:", error ?? "")
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.petImage.image = image
            }
        }.resume()
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        self.petImage.image = nil
        
        fetchCatImage()
    }
}
