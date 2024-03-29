//
//  RepoListViewReactor.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi
import RswiftResources
import HiIOS

class RepoListViewReactor: ListViewReactor {
    
    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
        self.pageStart = 0
        self.pageIndex = self.pageStart
    }
    
    override func fetchLocal() -> Observable<Mutation> {
        let models = Repo.cachedArray(page: self.page.rawValue) ?? []
        let original: [HiContent] = models.isNotEmpty ? [.init(header: nil, models: models)] : []
        return .just(.initial(original))
    }

//    override func requestRemote(_ mode: HiRequestMode, _ page: Int) -> Observable<Mutation> {
//        .create { [weak self] observer -> Disposable in
//            guard let `self` = self else { fatalError() }
//            return self.provider.trendingRepos()
//                 .asObservable()
//                 .map {
//                     mode != .loadMore ?
//                         .initial([.init(header: nil, models: $0)]) : .append([.init(header: nil, models: $0)])
//                 }
//                 .subscribe(observer)
//        }
//    }
    
}
