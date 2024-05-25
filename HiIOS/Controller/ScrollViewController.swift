//
//  ScrollViewController.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator_Hi
import DZNEmptyDataSet
import BonMot
import MJRefresh
import SwifterSwift
import HiCore
import HiDomain
import HiTheme

open class ScrollViewController: BaseViewController {
    
    public let emptyDataSetSubject = PublishSubject<Void>()
    public let refreshSubject = PublishSubject<Void>()
    public let loadMoreSubject = PublishSubject<Void>()
    public var scrollView: UIScrollView!
    
    public var shouldRefresh = false
    public var shouldLoadMore = false
    
    public var isLoading = false
    public var isRefreshing = false
    public var isLoadingMore = false
    
    public var noMoreData = false
    
    // MARK: - Init
    required public init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        super.init(navigator, reactor)
        var scrollView: UIScrollView!
        if self is TableViewController {
            scrollView = UITableView(frame: .zero)
        } else if self is CollectionViewController {
            // swiftlint:disable:next force_cast
            scrollView = UICollectionView(frame: .zero, collectionViewLayout: (self as! CollectionViewController).layout)
            // swiftlint:enable:next force_cast
        } else {
            scrollView = UIScrollView(frame: .zero)
        }
        scrollView.backgroundColor = .white
        scrollView.emptyDataSetSource = self
        scrollView.emptyDataSetDelegate = self
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        self.scrollView = scrollView
        // UITapGestureRecognizer(target: self, action: #selector(PopTip.handleTap(_:)))
        self.shouldRefresh = reactor.parameters.bool(for: Parameter.shouldRefresh) ?? false
        self.shouldLoadMore = reactor.parameters.bool(for: Parameter.shouldLoadMore) ?? false
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.scrollView)
        self.scrollView.frame = self.contentFrame
        
        self.setupRefresh(should: self.shouldRefresh)
        self.setupLoadMore(should: self.shouldLoadMore)
        
        self.scrollView.rx
            .setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.scrollView.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Method
    open override func bind(reactor: BaseViewReactor) {
        super.bind(reactor: reactor)
    }
    
}

extension ScrollViewController: DZNEmptyDataSetSource {
    
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
            return image.withAlignmentRectInsets(UIEdgeInsets(horizontal: (self.view.width - 120) / 2.f * -1.f, vertical: 0))
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

extension ScrollViewController: DZNEmptyDataSetDelegate {
    
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

extension ScrollViewController: UIScrollViewDelegate {
    
}

