//
//  EventViewReactor.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RswiftResources
import HiIOS

class EventViewReactor: ListViewReactor {
    
    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
//        self.initialState = State(
//            title: self.title ?? R.string.localizable.event(
//                preferredLanguages: myLangs
//            )
//        )
    }
    
//    override func fetchLocal() -> Observable<Mutation> {
//          let models = Event.cachedArray(page: self.host) ?? []
//          let original: [HiContent] = models.isNotEmpty ? [.init(header: nil, models: models)] : []
//        return .just(.initial(original))
//      }
//    
//    override func requestRemote(_ mode: HiRequestMode, _ page: Int) -> Observable<Mutation> {
//        .create { [weak self] observer -> Disposable in
//            guard let `self` = self else { fatalError() }
//            guard let username = self.currentState.user?.username, username.isNotEmpty else {
//                observer.onNext(.initial([]))
//                observer.onCompleted()
//                return Disposables.create { }
//            }
//            return self.provider.userEvents(username: username, page: page)
//                .asObservable()
//                .map {
//                    mode != .loadMore ?
//                        .initial([.init(header: nil, models: $0)]) : .append([.init(header: nil, models: $0)])
//                }
//                .subscribe(observer)
//        }
//    }

}
