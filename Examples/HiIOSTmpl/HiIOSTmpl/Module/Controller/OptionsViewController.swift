//
//  OptionsViewController.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/13.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import ReusableKit
import URLNavigator_Hi
import ObjectMapper_Hi
import RswiftResources
import RxDataSources
import RxGesture
import MessageUI
import HiIOS

class OptionsViewController: ListViewController {
    
    var closeBlock: ((String?) -> Void)?
    
    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        super.init(navigator, reactor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layerCornerRadius = 20
        self.navigationBar.style = .nosafe
        self.navigationBar.removeAllLeftButtons()
        self.navigationBar.removeAllRightButtons()
        self.navigationBar.addButtonToRight(image: UIImage.close).rx.tap
            .subscribeNext(weak: self, type(of: self).tapClose)
            .disposed(by: self.disposeBag)
        self.collectionView.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationBar.frame = .init(
            x: 0,
            y: 0,
            width: self.view.width,
            height: navigationBarHeight
        )
        self.collectionView.frame = .init(
            x: 0,
            y: self.navigationBar.bottom,
            width: self.view.width,
            height: self.view.height - self.navigationBar.bottom
        )
    }

    func tapClose(_: Void? = nil) {
        // self.closeBlock?(nil)
        self.closeBlock?("tapClose-abc123")
    }

}
