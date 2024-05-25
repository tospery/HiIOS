//
//  WebViewController.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit
import URLNavigator_Hi
import ReactorKit
import SwifterSwift
import HiCore
import HiDomain
import HiTheme
import HiNav
import HiJSBridge

open class WebViewController: ScrollViewController, View {
    
    public let estimatedProgress = "estimatedProgress"
    
    public var webView: WKWebView!
    public var url: URL?
    public var progressColor: UIColor?
    public var handlers = [String]()
    public var bridge: WKWebViewJavascriptBridge!

    public lazy var progressView: WebProgressView = {
        let view = WebProgressView(frame: .zero)
        view.sizeToFit()
        return view
    }()
    
    required public init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        defer {
            self.reactor = reactor as? WebViewReactor
        }
        super.init(navigator, reactor)
        self.url = reactor.parameters.url(for: Parameter.url)
        self.progressColor = reactor.parameters.color(for: Parameter.progressColor) ?? .primary
        self.handlers = reactor.parameters.array(for: Parameter.handers) as? [String] ?? []
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.webView = self.createWebView()
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.view.addSubview(self.webView)
        self.webView.frame = self.contentFrame
        
        self.progressView.barView.backgroundColor = self.progressColor ?? .primary
        self.view.addSubview(self.progressView)
        self.progressView.frame = CGRect(x: 0, y: self.contentTop, width: self.view.width, height: 1.5)
        
        self.webView.rx.observeWeakly(CGFloat.self, self.estimatedProgress, options: .new).subscribe(onNext: { [weak self] value in
            guard let `self` = self, let value = value else { return }
            self.progress(value)
        }).disposed(by: self.disposeBag)
        
        #if DEBUG
        WKWebViewJavascriptBridge.enableLogging()
        #endif
        self.bridge = WKWebViewJavascriptBridge.init(for: self.webView)
        self.bridge.setWebViewDelegate(self)
        for handler in self.handlers {
            self.bridge.registerHandler(handler) { [weak self] data, callback in
                guard let `self` = self else { return }
                let result = self.handle(handler, data)
                callback!(result) // 用Rx实现延迟的callback会更好
            }
        }
        
        self.loadPage()
        
        self.webView.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
        self.progressView.barView.theme.backgroundColor = themeService.attribute { $0.primaryColor }
    }
    
//    // YJX_TODO webView作为view，里面的scrollView暴露出来
//    open override func loadView() {
//        view = self.createWebView()
//        self.scrollView = (view as! WKWebView).scrollView
//    }
    
//    open override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.bridge.setWebViewDelegate(self)
//    }
//
//    open override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.bridge.setWebViewDelegate(nil)
//    }

    deinit {
        self.clear()
    }
    
    public func progress(_ value: CGFloat) {
        self.progressView.progress(value: value, animated: true)
        if self.navigationBar.titleLabel.text?.isEmpty ?? true {
            self.webView.evaluateJavaScript("document.title") { [weak self] response, _ in
                guard let `self` = self else { return }
                if let title = response as? String, title.isNotEmpty {
                    self.navigationBar.titleLabel.text = title
                } else {
                    self.navigationBar.titleLabel.text = self.url?.lastPathComponent
                }
            }
        }
    }

    open func createWebView() -> WKWebView {
        // configuration在传递给WKWebView后不能修改
        let configuration = WKWebViewConfiguration.init()
        configuration.userContentController = .init()
//        for handler in self.handlers {
//            if !handler.isEmpty {
//                configuration.userContentController.add(self, name: handler)
//            }
//        }
        let webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        webView.sizeToFit()
        return webView
    }

    open func loadPage() {
        guard let url = self.url else { return }
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        let extra = "\(UIApplication.shared.urlScheme)/\(UIApplication.shared.version!)"
        var agent = self.webView.customUserAgent
        if !(agent?.contains(extra) ?? false) {
            self.webView.evaluateJavaScript("navigator.userAgent") { [weak self] response, error in
                guard let `self` = self else { return }
                if let result = response as? String, error == nil {
                    agent = result + " " + extra
                    self.webView.customUserAgent = agent
                }
                self.webView.load(request)
            }
        } else {
            self.webView.load(request)
        }
    }
    
    open func handle(_ handler: String, _ data: Any?) -> Any? {
        nil
    }
    
    public func bind(reactor: WebViewReactor) {
        super.bind(reactor: reactor)
        // state
        reactor.state.map { $0.title }
            .distinctUntilChanged()
            .bind(to: self.navigationBar.titleLabel.rx.text)
            .disposed(by: self.disposeBag)
    }
    
    open override func didBack(type: BackType? = nil, result: Any? = nil) {
        super.didBack(type: type, result: result)
        self.clear()
    }
    
    func clear() {
        if self.webView != nil {
            self.webView.navigationDelegate = nil
            self.webView.uiDelegate = nil
        }
        self.bridge.setWebViewDelegate(nil)
    }
    
}

extension WebViewController: WKNavigationDelegate {

    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        logger.print("网址: \(navigationAction.request.url?.absoluteString ?? "")", module: .hiIOS)
        decisionHandler(.allow)
    }
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }

    open func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame ?? false == false {
            if let url = navigationAction.request.url {
                self.navigator.jump(url)
            }
        }
        return nil
    }
}

extension WebViewController: WKUIDelegate {
    
}

extension WebViewController: WKScriptMessageHandler {
    
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("\(message.name): \(message.body)")
        _ = self.handle(message.name, message.body)
    }
    
}


public extension Reactive where Base: WebViewController {
    var url: Binder<URL?> {
        return Binder(self.base) { viewController, url in
            viewController.url = url
        }
    }
}
