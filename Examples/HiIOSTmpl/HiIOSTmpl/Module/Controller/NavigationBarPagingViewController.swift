//
//  NavigationBarPagingViewController.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import UIKit
import HiIOS
import Parchment
import SnapKit

class NavigationBarPagingViewController: PagingViewController {

    override func loadView() {
        view = NavigationBarPagingView(
            options: options,
            collectionView: collectionView,
            pageView: pageViewController.view
        )
    }

}
