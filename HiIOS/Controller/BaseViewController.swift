//
//  BaseViewController.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SwifterSwift
import URLNavigator_Hi
import HiCore
import HiDomain
import HiTheme
import HiNav

public let statusBarService = BehaviorRelay<UIStatusBarStyle>(
    value: defaultStatusBarStyle()
)

func defaultStatusBarStyle() -> UIStatusBarStyle {
    guard let style = Bundle.main.infoDictionary?["UIStatusBarStyle"] as? String else {
        return UIApplication.shared.windows.first!.windowScene!.statusBarManager!.statusBarStyle
    }
    switch style {
    case "UIStatusBarStyleDefault":
        return .default
    case "UIStatusBarStyleLightContent":
        return .lightContent
    case "UIStatusBarStyleDarkContent":
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    default:
        return UIApplication.shared.windows.first!.windowScene!.statusBarManager!.statusBarStyle
    }
}

open class BaseViewController: UIViewController {
    
    public let parameters: [String: Any]
    /// 场景一：直接关闭，没有next，只有completed（如未登录时、点击TabBar需要登录的页面，只有next才展示）
    /// 场景一：需要登录的网络请求，如果登录成功、则继续网络请求；如果取消登录、则不进行网络请求
    public var callback: AnyObserver<Any>?
    private let mydealloc: PublishSubject<Void>!
    public var disposeBag = DisposeBag()
    public let navigator: NavigatorProtocol
    
    public var hidesNavigationBar   = false
    public var hidesNavBottomLine   = false
    public var transparetNavBar     = false {
        didSet {
            self.navigationBar.isTransparet = self.transparetNavBar
        }
    }
    public var navBarStyle   = NavigationBar.Style.automatic
    
    public var isActivating = false
    public var error: Error?
    
    open var contentTop: CGFloat {
        var height = self.navigationBar.height
        if self.hidesNavigationBar ||
            self.transparetNavBar ||
            self.navigationBar.isHidden ||
            self.navigationBar.isTransparet {
            if let navBar = self.navigationController?.navigationBar,
               navBar.isTranslucent == false {
                height = navigationBarHeight
            } else {
                height = 0
            }
        }
        return height
    }
    
    open var contentBottom: CGFloat {
        var height = 0.f
        if let tabBar = self.tabBarController?.tabBar,
           tabBar.isHidden == false,
           self.previous == nil,
           self.hidesBottomBarWhenPushed == false {
            height += tabBar.height
        }
        return height
    }
    
    open var contentFrame: CGRect {
        .init(
            x: 0,
            y: self.contentTop,
            width: self.view.width,
            height: self.view.height - self.contentTop - self.contentBottom
        )
    }
    
    // public let navigationBar = NavigationBar()
    
    lazy public var navigationBar: NavigationBar = {
        let navigationBar = NavigationBar()
        // navigationBar.layer.zPosition = .greatestFiniteMagnitude // -.greatestFiniteMagnitude
        navigationBar.sizeToFit()
        return navigationBar
    }()
    
    // MARK: - Init
    required public init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        self.mydealloc = reactor.mydealloc
        self.navigator = navigator
        self.parameters = reactor.parameters
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
        self.hidesNavigationBar = reactor.parameters.bool(for: Parameter.hidesNavigationBar) ?? false
        self.hidesNavBottomLine = reactor.parameters.bool(for: Parameter.hidesNavBottomLine) ?? false
        self.transparetNavBar = reactor.parameters.bool(for: Parameter.transparetNavBar) ?? false
        self.navBarStyle = .init(rawValue: reactor.parameters.int(for: Parameter.navBarStyle) ?? 0) ?? .automatic
        self.callback = reactor.parameters[Parameter.navObserver] as? AnyObserver<Any>
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
        logger.print("\(self.className)已销毁！！！", module: .hiIOS)
        #endif
    }
    
    // MARK: - View
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.edgesForExtendedLayout = .all
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationBar.style = self.navBarStyle
        self.view.addSubview(self.navigationBar)
        if self.hidesNavigationBar {
            self.navigationBar.isHidden = true
        } else {
            if self.transparetNavBar {
                self.navigationBar.transparet()
            } else {
                if self.hidesNavBottomLine {
                    self.navigationBar.borders = nil
                }
            }
            if self.navigationController?.viewControllers.count ?? 0 > 1 {
                self.navigationBar.addBackButtonToLeft().rx.tap.subscribe(onNext: { [weak self] _ in
                    guard let `self` = self else { return }
                    self.back(type: .popOne)
                }).disposed(by: self.disposeBag)
            } else {
                if self.isPresented {
                    self.navigationBar.addCloseButtonToLeft().rx.tap.subscribe(onNext: { [weak self] _ in
                        guard let `self` = self else { return }
                        self.back(type: .dismiss)
                    }).disposed(by: self.disposeBag)
                }
            }
        }
        
        if let gestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
            gestureRecognizer.addTarget(self, action: #selector(handleInteractivePopGestureRecognizer(_:)))
        }
        
        statusBarService.map { _ in () }.skip(1).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.setNeedsStatusBarAppearanceUpdate()
        }).disposed(by: self.rx.disposeBag)
        
        themeService.typeStream.skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] themeType in
                guard let `self` = self else { return }
                self.handleTheme(themeType)
            })
            .disposed(by: self.disposeBag)
        
        self.view.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
        self.navigationBar.theme.titleColor = themeService.attribute { $0.foregroundColor }
        self.navigationBar.theme.itemColor = themeService.attribute { $0.foregroundColor }
        self.navigationBar.theme.borderColor = themeService.attribute { $0.borderColor }
        self.navigationBar.theme.barColor = themeService.attribute { $0.backgroundColor }
        if !self.transparetNavBar {
            self.view.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
            self.navigationBar.theme.barColor = themeService.attribute { $0.backgroundColor }
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.hidesNavigationBar == false && self.transparetNavBar == false {
            self.navigationBar.setNeedsLayout()
            self.navigationBar.layoutIfNeeded()
        }
        self.view.bringSubviewToFront(self.navigationBar)
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarService.value
    }
    
    // MARK: - Method
    open func bind(reactor: BaseViewReactor) {
        reactor.navigator = self.navigator
    }
    
    public func tapBack(_: Void? = nil) {
        self.back(type: .auto)
    }
    
    open func back(
        type: BackType? = nil,
        result: Any? = nil,
        message: String? = nil,
        animated: Bool = true
    ) {
//        if result != nil && type != nil {
//#if DEBUG
//            logger.print("\(self.className)返回值：\(result!)", module: .hiIOS)
//#endif
//            self.callback?.onNext(result!)
//        }
        self.navigator.rxBack(type: type, animated: animated, message: message)
            .subscribe(onCompleted: { [weak self] in
                guard let `self` = self else { return }
                self.didBack(type: type, result: result)
            })
            .disposed(by: self.disposeBag)
    }
    
    open func didBack(type: BackType? = nil, result: Any? = nil) {
//        if type != nil {
//#if DEBUG
//            logger.print("\(self.className)返回：\(type)(\(data))", module: .hiIOS)
//#endif
//            self.callback?.onNext(BackResult(type: type, data: data))
//        }
        if result != nil {
            self.callback?.onNext(result!)
        }
        self.callback?.onCompleted()
        self.mydealloc.onNext(())
    }
    
    @objc func handleInteractivePopGestureRecognizer(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .ended:
            guard let superview = self.navigationController?.topViewController?.view.superview else { return }
            if superview.frame.minX == 0.f {
                self.didBack(type: .popOne)
            }
        default: break
        }
    }
    
    // MARK: handle
    open func handleTheme(_ themeType: ThemeType) {
    }
    
    open func handleTitle(_ text: String?) {
        self.tabBarItem.title = text
        self.navigationBar.titleLabel.text = text
        self.navigationBar.setNeedsLayout()
        self.navigationBar.layoutIfNeeded()
    }
    
    open func handleActivating(_ isActivating: Bool) {
        self.isActivating = isActivating
        guard self.isViewLoaded else { return }
        if isActivating {
            self.navigator.showToastActivity()
        } else {
            self.navigator.hideToastActivity()
        }
    }
    
    open func handleToast(_ message: String) {
        guard self.isViewLoaded else { return }
        guard !message.isEmpty else { return }
        self.navigator.toastMessage(message)
    }
    
    open func handleError(_ error: Error?) {
        self.error = error
        guard self.isViewLoaded else { return }
        guard let error = error?.asHiError else { return }
        if error.isNeedLogin {
            self.navigator.login()
        } else {
            if let scrollViewController = self as? ScrollViewController {
                if scrollViewController.isLoading {
                    return
                } else if scrollViewController.isRefreshing {
                    if error == .listIsEmpty {
                        return
                    }
                } else if scrollViewController.isLoadingMore {
                    if error == .listIsEmpty {
                        return
                    }
                }
            }
            if error == .none {
                return
            }
            self.navigator.toastMessage(error.localizedDescription, .failure)
        }
    }

}
