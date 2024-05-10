//
//  UIFont+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import UIKit

public extension UIFont {

    static func light(_ size: CGFloat) -> UIFont {
        .systemFont(ofSize: size, weight: .light)
    }
    
    static func medium(_ size: CGFloat) -> UIFont {
        .systemFont(ofSize: size, weight: .medium)
    }
    
    static func normal(_ size: CGFloat) -> UIFont {
        .systemFont(ofSize: size)
    }
    
    static func bold(_ size: CGFloat) -> UIFont {
        .boldSystemFont(ofSize: size)
    }

}
