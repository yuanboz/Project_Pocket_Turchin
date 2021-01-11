//
//  ImageService.swift
//  Project_PocketTurchin
//
//  Created by 周元博 on 1/11/21.
//

import Foundation
import UIKit

class ImageService {
    
    static let cache = NSCache<NSString, UIImage>()
    
    static func downloadImage(urlString: String, completion: @escaping (_ image: UIImage?) -> ()) {
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: {(data, _, err) in
                var downloadImage: UIImage?
                
                guard let data = data, err == nil else { return }
                downloadImage = UIImage(data: data)
                if downloadImage != nil {
                    cache.setObject(downloadImage!, forKey: url.absoluteString as NSString)
                }
                
                DispatchQueue.main.async {
                    completion(downloadImage)
                }
            }).resume()
        }
    }
    
    static func getImage(urlString: String, completion: @escaping (_ image: UIImage?) -> ()) {
        if let image = cache.object(forKey: urlString as NSString) {
            completion(image)
        } else {
            downloadImage(urlString: urlString, completion: completion)
        }
    }
    
}
