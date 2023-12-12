//
//  NavigationBarPagingView.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import UIKit
import HiIOS
import Parchment
import SnapKit

class NavigationBarPagingView: PagingView {

    override func setupConstraints() {
        pageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

}
