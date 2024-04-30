//
//  ImageSource.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import UIKit
import Kingfisher

//public enum ImageSourceType {
//    case url
//    case image
//}

public protocol ImageSource {
}

extension URL: ImageSource {}
extension UIImage: ImageSource {}


public func download(
    with source: ImageSource?,
    options: KingfisherOptionsInfo? = nil,
    alwaysTemplate: Bool = false,
    completion: ((UIImage?, HiError?) -> Void)? = nil
) {
    if source == nil {
        completion?(nil, nil)
        return
    }
    if let image = source as? UIImage {
        completion?(alwaysTemplate ? image.template : image, nil)
        return
    }
    
    if let url = source as? URL {
        ImageDownloader.default.downloadImage(with: url, options: options) { result in
            switch result {
            case .success(let image):
                completion?(image.image, nil)
            case .failure(let error):
                completion?(nil, error.asHiError)
            }
        }
    }
}
