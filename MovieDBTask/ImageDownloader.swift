//
//  ImageDownloader.swift
//  MovieDBTask
//
//  Created by Barath K on 13/05/22.
//

import Foundation
import SwiftUI

class ImageDownloader: ObservableObject {
    
    @Published var uiImage: UIImage? = nil
    private var urlString: String
    
    init(urlString: String){
        self.urlString = urlString
        downloadImageFromUrl()
    }
        
    private func downloadImageFromUrl(){
        self.uiImage = nil
        // Fetching image from cache
        if let image = ImageCache.imageCache.get(forKey: urlString) {
            self.uiImage = image
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                if let uiImage = UIImage(data: data) {
                    // saving to cache
                    ImageCache.imageCache.set(image: uiImage, forKey: self?.urlString ?? "")
                    self?.uiImage = uiImage
                }
            }
        }
        task.resume()
    }
}

/*
 Image Cache Handler
*/
class ImageCache {
    
    private var cache = NSCache<NSString, UIImage>()
    static let imageCache = ImageCache()
    
    private init(){}
    
    func get(forKey: String) -> UIImage? {
        return cache.object(forKey: NSString(string: forKey))
    }
    
    func set(image: UIImage, forKey: String) {
        cache.setObject(image, forKey: NSString(string: forKey))
    }
}

