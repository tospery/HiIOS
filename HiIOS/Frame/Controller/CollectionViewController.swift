//
//  CollectionViewController.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import URLNavigator_Hi

open class CollectionViewController: ScrollViewController {

    public var collectionView: UICollectionView!
    open var layout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }
    
    required public init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        super.init(navigator, reactor)
        self.collectionView = (self.scrollView as! UICollectionView)
        self.collectionView.alwaysBounceVertical = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
    }
    
}
