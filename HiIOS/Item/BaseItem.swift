//
//  BaseItem.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import Foundation

open class BaseItem: ModelViewReactor {
    
    public var size = CGSize.zero
    public weak var parent: BaseViewReactor?
    
}

