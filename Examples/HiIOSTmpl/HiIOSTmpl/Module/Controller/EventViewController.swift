//
//  EventViewController.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RswiftResources
import ReusableKit
import ObjectMapper_Hi
import RxDataSources
import RxGesture
import HiIOS

class EventViewController: ListViewController {
    
    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        super.init(navigator, reactor)
        self.shouldRefresh = reactor.parameters.bool(for: Parameter.shouldRefresh) ?? true
        self.shouldLoadMore = reactor.parameters.bool(for: Parameter.shouldLoadMore) ?? false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

//    override func handleContents(contents: [HiContent]) {
//        guard let host = self.reactor?.host, host.isNotEmpty else { return }
//        guard let index = self.reactor?.pageIndex, index == self.reactor?.pageStart else { return }
//        guard let events = contents.first?.models as? [Event], events.isNotEmpty else { return }
//        let first = [Event].init(events.prefix(self.reactor?.pageSize ?? UIApplication.shared.pageSize))
//        Event.storeArray(first, page: host)
//        log("event缓存->\(host)【首页.事件】")
//    }
    
}
