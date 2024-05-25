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
import HiCore


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
        alwaysTemplate: Bool = false,
        completion: ((HiError?) -> Void)? = nil
    ) -> Binder<ImageSource?> {
        return Binder(self.base) { imageView, resource in
            imageView.setImageResource(
                with: resource,
                placeholder: placeholder,
                options: options,
                alwaysTemplate: alwaysTemplate,
                completion: completion
            )
        }
    }
    
}

