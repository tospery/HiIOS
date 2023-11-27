//
//  WebViewController.swift
//  IOSTemplate
//
//  Created by liaoya on 2021/6/28.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import Rswift
import HiIOS

class WebViewController: HiIOS.WebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadPage() {
        super.loadPage()
    }
    
    override func handle(_ handler: String, _ data: Any?) -> Any? {
        log("未处理的JS: \(handler)")
        return nil
    }
    
    override func webView(_ webView: WKWebView,
                          decidePolicyFor navigationAction: WKNavigationAction,
                          decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        super.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
    }
    
}
