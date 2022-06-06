//
//  WebService.swift
//  piscum.photos
//
//  Created by Danial Fajar on 05/06/2022.
//

import UIKit
import Kingfisher

typealias Parameters = [String: String]

enum imageStatus: String {
    case success
    case failure
}

public class WebService {
    // MARK: - getData
    /// - parameter url:                Compulsary for api url
    /// - parameter httpBody:           Optional if need pass data to webservice
    /// - parameter completionHandler:  The completion handler data, just pass return data to viewcontroller
    func getData(_ url: String, completion: @escaping ((_ data: Data)->())){
        let encodedUrl = url.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: encodedUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Set HTTP Request Header
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 300
        config.timeoutIntervalForRequest = 300
        
        URLSession(configuration: config).dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            completion(data)
        }.resume()
    }
    
    // MARK: - loadImageData
      /// - parameter parentImgView:      Optional to put UIView to loading shimmering
      /// - parameter imageView:          Compulsory to put imageView to assign new image
      /// - parameter imageURL:           Passed image url (string or url) only to load image, check with status to show image **(not necessary to convert to URL)
      /// - parameter defaultImage:       Default image as placeholder image if imageURL is nil
      /// - parameter completionHandler:  The completion handler image, just pass image to UIImage.image
    static func loadImageData(_ imageView: UIImageView,
                              imageURL: String,
                              defaultImage: UIImage,
                              completionHandler: @escaping (_ status: imageStatus)->Void) {
        
        // convert http url to https
        var comps = URLComponents(string: imageURL)
        comps?.scheme = "https"
        let httpsImageURL = comps?.string ?? ""
        let url = URL(string: httpsImageURL)
        
        let processor = DownsamplingImageProcessor(size: imageView.bounds.size)
        
        imageView.kf.indicatorType = .activity
        
        // retrieve from request url
        if ImageCache.default.isCached(forKey: url?.cacheKey ?? "") {
            ImageCache.default.retrieveImage(forKey: url?.cacheKey ?? "") { result in
                switch result {
                case .success(let value):
                    print("Done fetch from cache image")
                    value.image?.prepareForDisplay { decodedImage in // to avoid lagging
                        DispatchQueue.main.async {
                            imageView.image = decodedImage
                        }
                    }
                    completionHandler(imageStatus.success)
                case .failure:
                    print("Failed fetch from cache image")
                    DispatchQueue.main.async {
                        imageView.image = defaultImage
                    }
                    completionHandler(imageStatus.failure)
                }
            }
        } else {
            imageView.kf.setImage(
                with: url,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ])
            {
                result in
                switch result {
                case .success(let value):
                    print("Done fetch for: \(value.source.url?.absoluteString ?? "")")
                    completionHandler(imageStatus.success)
                case .failure(let error):
                    print("Fetch failed: \(error.localizedDescription)")
                    completionHandler(imageStatus.failure)
                }
            }
        }
    }
    
    static func prefetchImageData(urls: [URL]) {
        ImagePrefetcher(urls: urls).start()
    }
}
