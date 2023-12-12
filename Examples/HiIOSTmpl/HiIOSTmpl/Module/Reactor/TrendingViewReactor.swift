//
//  TrendingViewReactor.swift
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
import Parchment
import HiIOS

class TrendingViewReactor: ScrollViewReactor, ReactorKit.Reactor {

    enum Action {
        case load
    }

    enum Mutation {
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setLoadingMore(Bool)
        case setTitle(String?)
        case setError(Error?)
        case setUser(User?)
        case setConfiguration(Configuration)
        case setPages([Page])
    }

    struct State {
        var isLoading = false
        var isRefreshing = false
        var isLoadingMore = false
        var noMoreData = false
        var error: Error?
        var title: String?
        var user: User?
        var configuration = Configuration.current!
        var pages = [Page].init()
    }

    var initialState = State()

    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
        self.initialState = State(
            title: self.title ?? R.string(preferredLanguages: myLangs).localizable.trending(),
            pages: Page.trendingValues
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load: return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        case let .setRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        case let .setLoadingMore(isLoadingMore):
            newState.isLoadingMore = isLoadingMore
        case let .setTitle(title):
            newState.title = title
        case let .setError(error):
            newState.error = error
        case let .setUser(user):
            newState.user = user
        case let .setConfiguration(configuration):
            newState.configuration = configuration
        case let .setPages(pages):
            newState.pages = pages
        }
        return newState
    }
    
    func transform(action: Observable<Action>) -> Observable<Action> {
        action
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        .merge(
            mutation,
            Subjection.for(User.self)
                .distinctUntilChanged()
                .asObservable()
                .map(Mutation.setUser),
            Subjection.for(Configuration.self)
                .distinctUntilChanged()
                .filterNil()
                .asObservable()
                .map(Mutation.setConfiguration)
        )
    }
    
    func transform(state: Observable<State>) -> Observable<State> {
        state
    }
    
}

extension TrendingViewReactor: PagingViewControllerDataSource {
    
    func numberOfViewControllers(
        in pagingViewController: PagingViewController
    ) -> Int {
        self.currentState.pages.count
    }

    func pagingViewController(
        _ pagingViewController: PagingViewController,
        viewControllerAt index: Int
    ) -> UIViewController {
        let page = self.currentState.pages[index]
        switch page {
        case .trendingRepos:
            return self.navigator.viewController(
                for: Router.shared.urlString(
                    host: .repo,
                    path: .list,
                    parameters: [
                        Parameter.hidesNavigationBar: true.string,
                        Parameter.pagingElement: page.rawValue
                    ]
                )
            )!
        default:
            return self.navigator.viewController(
                for: Router.shared.urlString(
                    host: .user,
                    path: .list,
                    parameters: [
                        Parameter.hidesNavigationBar: true.string,
                        Parameter.pagingElement: page.rawValue
                    ]
                )
            )!
        }
    }

    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        PagingIndexItem(index: index, title: self.currentState.pages[index].title ?? "")
    }
}
