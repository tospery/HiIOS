//
//  WKWebView+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa

public extension Reactive where Base: WKWebView {

    var loadHTMLString: Binder<String> {
        return Binder(self.base) { webView, string in
            webView.loadHTMLString(string, baseURL: nil)
        }
    }

    var load: Binder<URL> {
        return Binder(self.base) { webView, url in
            webView.load(URLRequest(url: url))
        }
    }

}
