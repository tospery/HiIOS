//
//  ImageViewCell.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/11.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi
import RswiftResources
import HiIOS

class ImageViewCell: BaseCollectionCell, ReactorKit.View {
    
    struct Metric {
        static let height = deviceHeight - navigationContentTopConstant
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.sizeToFit()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.sizeToFit()
        self.imageView.frame = self.contentView.bounds
    }

    func bind(reactor: ImageViewItem) {
        super.bind(item: reactor)
        reactor.state.map { $0.image }
            .distinctUntilChanged { HiIOS.compareImage($0, $1) }
            .bind(to: self.imageView.rx.imageResource(placeholder: R.image.ic_user_default()))
            .disposed(by: self.disposeBag)
        reactor.state.map { _ in }
            .bind(to: self.rx.setNeedsLayout)
            .disposed(by: self.disposeBag)
    }
    
    override class func size(width: CGFloat, item: BaseCollectionItem) -> CGSize {
        .init(width: width, height: Metric.height)
    }

}
