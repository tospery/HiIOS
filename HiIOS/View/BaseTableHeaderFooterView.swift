//
//  BaseTableHeaderFooterView.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import HiTheme

open class BaseTableHeaderFooterView: UITableViewHeaderFooterView {

    public var disposeBag = DisposeBag()

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }

    open func bind(reactor: BaseViewReactor) {
    }

}
