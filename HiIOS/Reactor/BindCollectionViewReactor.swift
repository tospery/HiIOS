//
//  BindCollectionViewReactor.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/3/19.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit
import URLNavigator_Hi
import ObjectMapper
import HiCore
import HiDomain

open class BindCollectionViewReactor: CollectionViewReactor, ReactorKit.Reactor {

    public enum Action {
        case load
        case refresh
        case loadMore
        case update
        case reload
        case target(String?)
        case data(Any?)
        case execute(value: Any?, active: Bool, needLogin: Bool)
    }

    public enum Mutation {
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setLoadingMore(Bool)
        case setActivating(Bool)
        case setError(Error?)
        case setTitle(String?)
        case setTarget(String?)
        case setData(Any?)
        // case setProfile((any ModelType)?)
        // case setUser((any ModelType)?)
        case setProfile((any ProfileType)?)
        case initial([HiContent])
        case append([HiContent])
    }

    public struct State {
        public var isLoading = false
        public var isRefreshing = false
        public var isActivating = false
        public var isLoadingMore = false
        public var noMoreData = false
        public var title: String?
        public var target: String?
        public var error: Error?
        public var data: Any?
//        public var current: (any ModelType)?
//        public var user: (any ModelType)? = nil
        public var profile: (any ProfileType)?
        public var contents = [HiContent].init()
        public var sections = [any SectionModelType].init()
    }
    
    public let url: String
    public var initialState = State()

    required public init(_ provider: HiDomain.ProviderProtocol, _ parameters: [String: Any]?) {
        self.url = parameters?.string(for: Parameter.url) ?? ""
        super.init(provider, parameters)
        self.initialState = State(
            title: self.title
        )
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load: return self.load()
        case .update: return self.update()
        case .refresh: return self.refresh()
        case .loadMore: return self.loadMore()
        case .reload: return self.reload()
        case let .target(target):
            guard let target = target?.url?.appendingQueryParameters([
                Parameter.navTimestamp: (Date().timeIntervalSince1970 * 1000).int.string
            ]).absoluteString else { return .empty() }
            return .just(.setTarget(target))
        case let .data(data): return .just(.setData(data))
        case let .execute(value, active, needLogin): return self.execute(value, active, needLogin)
        }
    }
    
    open func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        case let .setRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
        case let .setLoadingMore(isLoadingMore):
            newState.isLoadingMore = isLoadingMore
        case let .setActivating(isActivating):
            newState.isActivating = isActivating
        case let .setError(error):
            newState.error = error
        case let .setTitle(title):
            newState.title = title
        case let .setTarget(target):
            newState.target = target
        case let .setData(data):
            newState.data = data
//        case let .setProfile(current):
//            newState.current = current
//        case let .setUser(user):
//            newState.user = user
        case let .setProfile(profile):
            newState.profile = profile
        case let .initial(data):
            newState.contents = self.append(data, to: [])
            newState.sections = self.convert(contents: newState.contents)
            newState.noMoreData = newState.contents.last?.models.count ?? 0 < self.pageSize
        case let .append(added):
            newState.contents = self.append(added, to: newState.contents)
            newState.sections = self.convert(contents: newState.contents)
            newState.noMoreData = newState.contents.last?.models.count ?? 0 < self.pageSize
        }
        return newState
    }
    
    open func transform(action: Observable<Action>) -> Observable<Action> {
        action
    }
    
    open func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        mutation
    }
    
    open func transform(state: Observable<State>) -> Observable<State> {
        state
    }

    // MARK: - actions
    open func load() -> Observable<Mutation> {
        .concat([
            self.fetchLocal(),
            .just(.setError(nil)),
            .just(.setLoading(true)),
            self.requestRemote(.load, self.pageStart),
            .just(.setLoading(false))
        ]).do(onCompleted: { [weak self] in
            guard let `self` = self else { return }
            self.pageIndex = self.pageStart
        }).catch({
            .concat([
                .just(.initial([])),
                .just(.setError($0)),
                .just(.setLoading(false))
            ])
        })
    }
    
    open func refresh() -> Observable<Mutation> {
        .concat([
            .just(.setError(nil)),
            .just(.setRefreshing(true)),
            self.requestRemote(.refresh, self.pageStart),
            .just(.setRefreshing(false))
        ]).do(onCompleted: { [weak self] in
            guard let `self` = self else { return }
            self.pageIndex = self.pageStart
        }).catch({
            .concat([
                .just(.setError($0)),
                .just(.setRefreshing(false))
            ])
        })
    }
    
    open func loadMore() -> Observable<Mutation> {
        .concat([
            .just(.setError(nil)),
            .just(.setLoadingMore(true)),
            self.requestRemote(.loadMore, self.pageIndex + 1),
            .just(.setLoadingMore(false))
        ]).do(onCompleted: { [weak self] in
            guard let `self` = self else { return }
            self.pageIndex += 1
        }).catch({
            .concat([
                .just(.setError($0)),
                .just(.setLoadingMore(false))
            ])
        })
    }
    
    open func reload() -> Observable<Mutation> {
        self.load()
    }
    
    open func update() -> Observable<Mutation> {
        .empty()
    }
    
    open func execute(_ value: Any?, _ active: Bool, _ needLogin: Bool) -> Observable<Mutation> {
        if active {
            guard !self.currentState.isActivating else { return .empty() }
        }
        return .concat([
            .just(.setError(nil)),
            needLogin ? self.checkLogin() : .empty(),
            active ? .just(.setActivating(true)) : .empty(),
            active ? self.active(value) : self.silent(value),
            active ? .just(.setActivating(false)) : .empty()
        ]).catch({
            .concat([
                .just(.setError($0)),
                active ? .just(.setActivating(false)) : .empty()
            ])
        })
    }
    
    // MARK: - fetch/request
    open func fetchLocal() -> Observable<Mutation> {
        .just(.initial([]))
    }
    
    open func requestRemote(_ mode: HiRequestMode, _ page: Int) -> Observable<Mutation> {
        .empty()
    }
    
    // MARK: - active/silent
    open func active(_ value: Any?) -> Observable<Mutation> {
        .empty()
    }
    
    open func silent(_ value: Any?) -> Observable<Mutation> {
        .empty()
    }
    
    // MARK: - sections
    open func append(
        _ addition: [HiContent],
        to existing: [HiContent]
    ) -> [HiContent] {
        var contents = [HiContent].init()
        if existing.isEmpty {
            contents = addition
        } else {
            if existing.last?.header == nil {
                var models = existing.last?.models ?? []
                models.append(contentsOf: addition.last?.models ?? [])
                contents = [HiContent.init(header: nil, models: models)]
            } else {
                contents.append(contentsOf: existing)
                contents.append(contentsOf: addition)
            }
        }
        return contents
    }
    
    open func convert(contents: [HiContent]) -> [any SectionModelType] {
        []
    }
    
    // MARK: - other
    open func checkLogin() -> Observable<Mutation> {
        .create { [weak self] observer -> Disposable in
            guard let `self` = self else { fatalError() }
            if self.currentState.profile?.loginedUser?.isValid ?? false {
                observer.onCompleted()
                return Disposables.create { }
            }
            return self.navigator.rxLogin()
                .map { [weak self] user in
                    guard let `self` = self else { fatalError() }
                    var profile = self.currentState.profile
                    profile?.loginedUser = user as? (any UserType)
                    return .setProfile(profile)
                }
                .subscribe(observer)
        }
    }

}

extension BindCollectionViewReactor.Action {
    
    static func isLoad(_ action: BindCollectionViewReactor.Action) -> Bool {
        if case .load = action {
            return true
        }
        return false
    }
    
}
