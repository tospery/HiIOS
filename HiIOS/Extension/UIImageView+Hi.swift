//
//  UIImageView+Hi.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/4/29.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import HiCore


public extension UIImageView {
    
    func setImageResource(
        with resource: ImageSource?,
        placeholder: Placeholder? = nil,
        options: KingfisherOptionsInfo? = nil,
        alwaysTemplate: Bool = false,
        completion: ((HiError?) -> Void)? = nil
    ) {
        if resource == nil && placeholder == nil {
            self.image = nil
            return
        }
        if let image = resource as? UIImage {
            self.image = alwaysTemplate ? image.template : image
        } else if let url = resource as? URL {
            self.kf.setImage(with: url, placeholder: placeholder, options: options) { result in
                if completion == nil {
                    return
                }
                switch result {
                case .failure(let error):
                    completion!(error.hiError)
                default:
                    completion!(nil)
                }
            }
        } else {
            placeholder?.add(to: self)
        }
    }
    
}
