//
//  UIImageView+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

public extension Reactive where Base: UIImageView {
        
    var imageSource: Binder<ImageSource?> {
        return Binder(self.base) { imageView, resource in
            imageView.isHidden = false
            if let image = resource as? UIImage {
                imageView.image = image
            } else if let url = resource as? URL {
                imageView.kf.setImage(with: url)
            } else {
                imageView.isHidden = true
            }
        }
    }
    
    func imageResource(
        placeholder: Placeholder? = nil,
        options: KingfisherOptionsInfo? = nil,
        alwaysTemplate: Bool = false
    ) -> Binder<ImageSource?> {
        return Binder(self.base) { imageView, resource in
            if resource == nil {
                imageView.image = nil
                return
            }
            if let image = resource as? UIImage {
                imageView.image = alwaysTemplate ? image.template : image
            } else if let url = resource as? URL {
                imageView.kf.setImage(with: url, placeholder: placeholder, options: options)
            } else {
                placeholder?.add(to: imageView)
            }
        }
    }
    
}

