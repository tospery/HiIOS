//
//  UICollectionView+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public extension Reactive where Base: UICollectionView {
    
    func itemSelected<Section>(dataSource: CollectionViewSectionedDataSource<Section>) -> ControlEvent<Section.Item> {
        let source = self.itemSelected.map { indexPath in
            dataSource[indexPath]
        }
        return ControlEvent(events: source)
    }
    
}

