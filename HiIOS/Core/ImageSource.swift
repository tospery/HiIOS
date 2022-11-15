//
//  ImageSource.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import UIKit

//public enum ImageSourceType {
//    case url
//    case image
//}

public protocol ImageSource {
}

extension URL: ImageSource {}
extension UIImage: ImageSource {}
