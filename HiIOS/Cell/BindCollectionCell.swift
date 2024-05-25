//
//  BindCollectionCell.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/4/30.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh
import ReactorKit
import DZNEmptyDataSet
import SwifterSwift
import HiCore

import HiTheme
import HiNav

open class BindCollectionCell: BaseCollectionCell, ReactorKit.View {
    
    struct Metric {
        static let height = deviceHeight - navigationContentTopConstant
    }
    
    public var isLoading = true
    public var error: Error?
    public let emptyDataSetSubject = PublishSubject<Void>()
    
    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView.init(frame: .zero)
        scrollView.emptyDataSetSource = self
        scrollView.emptyDataSetDelegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
        return scrollView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.scrollView)
        self.scrollView.rx
            .setDelegate(self)
            .disposed(by: self.disposeBag)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.contentView.bounds
    }
    
    open func bind(reactor: BindCollectionItem) {
        super.bind(item: reactor)
        self.rx.load.map { Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: self.rx.loading)
            .disposed(by: self.disposeBag)
//        reactor.state.map { $0.param }
//            .distinctUntilChanged { HiCore.compareAny($0, $1) }
//            //.delay(.milliseconds(100), scheduler: ConcurrentDispatchQueueScheduler.init(qos: .background))
//            //.observe(on: MainScheduler.asyncInstance)
//            .skip(1)
//            .subscribeNext(weak: self, type(of: self).handleParam)
//            .disposed(by: self.disposeBag)
        reactor.state.map { $0.data }
            .distinctUntilChanged { HiCore.compareAny($0, $1) }
            .skip(1)
            .subscribeNext(weak: self, type(of: self).handleData)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.error }
            .distinctUntilChanged({ $0?.asHiError == $1?.asHiError })
            .bind(to: self.rx.error)
            .disposed(by: self.disposeBag)
        reactor.state.map { _ in }
            .bind(to: self.rx.setNeedsLayout)
            .disposed(by: self.disposeBag)
    }
    
    open func request() {
        
    }
    
//    open func handleParam(param: Any?) {
//        // self.reactor?.action.onNext(.load)
//    }
    
    open func handleData(data: Any?) {
    }
    
    open func handleError(_ error: Error?) {
        self.error = error
    }
    
    open override class func size(width: CGFloat, item: BaseCollectionItem) -> CGSize {
        .init(width: width, height: Metric.height)
    }
}

extension BindCollectionCell: DZNEmptyDataSetSource {
    
    open func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if let title = self.error?.asHiError.failureReason, !title.isEmpty {
            return title.styled(with: .alignment(.center),
                                .font(.bold(20)),
                                .color(.foreground))
        }
        return nil
    }
    
    open func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if let message = self.error?.asHiError.errorDescription, !message.isEmpty {
            return message.styled(with: .alignment(.center),
                                  .font(.normal(14)),
                                  .color(.foreground))
        }
        return nil
    }
    
    open func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if self.isLoading == false && self.error != nil {
            return self.error?.asHiError.displayImage
        }
        return UIImage.loading.withTintColor(.primary, renderingMode: .alwaysTemplate)
    }
    
    open func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        if let retry = self.error?.asHiError.recoverySuggestion {
            return retry.styled(with: .font(.normal(15)),
                                .color(state == UIControl.State.normal ? UIColor.background : UIColor.background.withAlphaComponent(0.8)))
        }
        return nil
    }
    
    open func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> UIImage! {
        if state == UIControl.State.normal,
            let image = UIImage.init(color: .primary, size: .init(width: 120, height: 40)).withRoundedCorners(radius: 2) {
            return image.withAlignmentRectInsets(UIEdgeInsets(horizontal: (self.contentView.width - 120) / 2.f * -1.f, vertical: 0))
        }
        return nil
    }
    
    open func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0.0, 0.0, 1.0))
        animation.duration = 0.25
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    open func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        .clear
    }
    
    open func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        if self.error != nil {
            return -80
        }
        return 0
    }
    
}

extension BindCollectionCell: DZNEmptyDataSetDelegate {
    
    public func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        let should = (self.isLoading == true || self.error != nil)
        return should
    }

    public func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
        let should = (self.isLoading == true && self.error == nil)
        return should
    }
    
    public func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        self.emptyDataSetSubject.onNext(())
    }
    
    public func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.emptyDataSetSubject.onNext(())
    }
    
}

extension BindCollectionCell: UIScrollViewDelegate {
    
}

