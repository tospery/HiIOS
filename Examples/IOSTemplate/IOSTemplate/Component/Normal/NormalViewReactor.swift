//
//  NormalViewReactor.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2022/10/3.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import Rswift
import HiIOS

class NormalViewReactor: HiIOS.CollectionViewReactor, ReactorKit.Reactor {

    enum Action {
        case load
        case refresh
        case loadMore
        case reload
        case activate(Any?)
        case target(String)
    }

    enum Mutation {
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setLoadingMore(Bool)
        case setActivating(Bool)
        case setTitle(String?)
        case setError(Error?)
        case setUser(User?)
        case setConfiguration(Configuration)
        case setTarget(String?)
        case initial([HiContent])
        case append([HiContent])
    }

    struct State {
        var isLoading = false
        var isRefreshing = false
        var isLoadingMore = false
        var isActivating = false
        var noMoreData = false
        var error: Error?
        var title: String?
        var user: User?
        var configuration = Configuration.current!
        var target: String?
        var originals = [HiContent].init()
        var additions = [HiContent].init()
        var sections = [Section].init()
    }

    let username: String!
    var initialState = State()

    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        self.username = parameters?.string(for: Parameter.username)
        super.init(provider, parameters)
        self.pageStart = 0
        self.pageIndex = self.pageStart
        self.initialState = State(
            title: self.title
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load:
            return self.load()
        case .refresh:
            return self.refresh()
        case .loadMore:
            return self.loadMore()
        case .reload:
            return self.reload()
        case let .activate(data):
            return self.activate(data)
        case let .target(target):
            return .concat([
                .just(.setTarget(nil)),
                .just(.setTarget(target))
            ])
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    func reduce(state: State, mutation: Mutation) -> State {
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
        case let .setTitle(title):
            newState.title = title
        case let .setError(error):
            newState.error = error
        case let .setUser(user):
            newState.user = user
        case let .setConfiguration(configuration):
            newState.configuration = configuration
        case let .setTarget(target):
            newState.target = target
        case let .initial(data):
            newState.originals = data
            return self.reduceSections(newState, additional: false)
        case let .append(additions):
            newState.additions = additions
            return self.reduceSections(newState, additional: true)
        }
        return newState
    }
    // swiftlint:enable cyclomatic_complexity
    
    func transform(action: Observable<Action>) -> Observable<Action> {
        action
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return .merge(
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

    // MARK: - actions
    func load() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setError(nil)),
            .just(.setLoading(true)),
            self.loadDependency(),
            self.loadData(self.pageStart)
                .map(Mutation.initial),
            .just(.setLoading(false)),
            self.loadExtra()
        ]).catch({
            .concat([
                .just(.initial([])),
                .just(.setError($0)),
                .just(.setLoading(false))
            ])
        })
    }
    
    func refresh() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setError(nil)),
            .just(.setRefreshing(true)),
            self.loadData(self.pageStart)
                .errorOnEmpty()
                .map(Mutation.initial),
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
    
    func loadMore() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setError(nil)),
            .just(.setLoadingMore(true)),
            self.loadData(self.pageIndex + 1)
                .errorOnEmpty()
                .map(Mutation.append),
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
    
    func activate(_ data: Any?) -> Observable<Mutation> {
        guard !self.currentState.isActivating else { return .empty() }
        return .concat([
            .just(.setError(nil)),
            .just(.setActivating(true)),
            self.business(data),
            .just(.setActivating(false))
        ]).catch({
            .concat([
                .just(.setError($0)),
                .just(.setActivating(false))
            ])
        })
    }
    
    func reload() -> Observable<Mutation> {
        .empty()
    }
    
    func business(_ data: Any?) -> Observable<Mutation> {
        .empty()
    }
    
    func silent(_ data: Any?) -> Observable<Mutation> {
        .empty()
    }
    
    func reduceSections(_ state: State, additional: Bool) -> State {
        var newState = state
        var noMore = false
        if additional {
            if newState.originals.isEmpty {
                newState.originals = newState.additions
                noMore = (newState.additions.first?.models ?? []).count < self.pageSize
            } else {
                if newState.originals.first!.header == nil {
                    var models = [ModelType].init()
                    models.append(contentsOf: newState.originals.first!.models)
                    models.append(contentsOf: newState.additions.first?.models ?? [])
                    newState.originals = models.count == 0 ? [] : [HiContent.init(header: nil, models: models)]
                    noMore = (newState.additions.first?.models ?? []).count < self.pageSize
                } else {
                    var data = [HiContent].init()
                    data.append(contentsOf: newState.originals)
                    data.append(contentsOf: newState.additions)
                    newState.originals = data
                }
            }
        } else {
            noMore = newState.originals.first?.models.count ?? 0 < self.pageSize
        }
        newState.noMoreData = noMore
        newState.sections = self.genSections(originals: newState.originals)
        return newState
    }
    
    func genSections(originals: [HiContent]) -> [Section] {
        (originals.count == 0 ? [] : originals.map {
            .sectionItems(header: $0.header, items: $0.models.map {
                return .simple(.init($0))
            })
        })
    }
    
    // MARK: - dependency/data
    func loadDependency() -> Observable<Mutation> {
        .empty()
    }
    
    func loadData(_ page: Int) -> Observable<[HiContent]> {
        .empty()
    }
    
    func loadExtra() -> Observable<Mutation> {
        .empty()
    }
    
}

extension NormalViewReactor.Action {
    
    static func isLoad(_ action: NormalViewReactor.Action) -> Bool {
        if case .load = action {
            return true
        }
        return false
    }
    
}
