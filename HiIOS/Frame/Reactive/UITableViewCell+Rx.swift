//
//  UITableViewCell+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UITableViewCell {
    
    var accessoryType: Binder<UITableViewCell.AccessoryType> {
        return Binder(self.base) { cell, accessoryType in
            cell.accessoryType = accessoryType
        }
    }

}
