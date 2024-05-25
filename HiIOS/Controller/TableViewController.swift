//
//  TableViewController.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import URLNavigator_Hi
import HiCore

import HiTheme
import HiNav

open class TableViewController: ScrollViewController {
    
    public var tableView: UITableView!
    
    required public init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        super.init(navigator, reactor)
        // swiftlint:disable:next force_cast
        self.tableView = (self.scrollView as! UITableView)
        // swiftlint:enable:next force_cast
        self.tableView.separatorStyle = .none
        self.tableView.alwaysBounceVertical = true
        self.tableView.tableFooterView = .init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
    }
}
