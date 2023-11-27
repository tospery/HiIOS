//
//  ListViewReactor.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2022/10/3.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import RxSwiftExt
import RxOptional
import URLNavigator
import Rswift
import HiIOS

// swiftlint:disable type_body_length
class ListViewReactor: HiIOS.CollectionViewReactor, ReactorKit.Reactor {

    enum Action {
        case load
        case refresh
        case loadMore
        case update
        case reload
        case target(String?)
        case data(Any?)
        case execute(value: Any?, active: Bool, needLogin: Bool)
    }

    enum Mutation {
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setLoadingMore(Bool)
        case setActivating(Bool)
        case setError(Error?)
        case setTitle(String?)
        case setTarget(String?)
        case setData(Any?)
        case setUser(User?)
        case setConfiguration(Configuration)
        case initial([HiContent])
        case append([HiContent])
    }

    struct State {
        var isLoading = false
        var isRefreshing = false
        var isActivating = false
        var isLoadingMore = false
        var noMoreData = false
        var error: Error?
        var title: String?
        var target: String?
        var data: Any?
        var user = User.current
        var configuration = Configuration.current!
        var contents = [HiContent].init()
        var sections = [Section].init()
    }
    
    let url: String
    let page: Page
    let username: String
    let reponame: String
    var initialState = State()

    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        self.url = parameters?.string(for: Parameter.url) ?? ""
        self.page = parameters?.enum(for: Parameter.page, type: Page.self) ?? Page.none
        self.username = parameters?.string(for: Parameter.username) ?? ""
        self.reponame = parameters?.string(for: Parameter.reponame) ?? ""
        super.init(provider, parameters)
        self.initialState = State(
            title: self.title
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load: return self.load()
        case .update: return self.update()
        case .refresh: return self.refresh()
        case .loadMore: return self.loadMore()
        case .reload: return self.reload()
        case let .target(target):
            guard let target = target?.url?.appendingQueryParameters([
                Parameter.routerTimestamp: (Date().timeIntervalSince1970 * 1000).int.string
            ]).absoluteString else { return .empty() }
            return .just(.setTarget(target))
        case let .data(data): return .just(.setData(data))
        case let .execute(value, active, needLogin): return self.execute(value, active, needLogin)
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
        case let .setError(error):
            newState.error = error
        case let .setTitle(title):
            newState.title = title
        case let .setTarget(target):
            newState.target = target
        case let .setData(data):
            newState.data = data
        case let .setUser(user):
            newState.user = user
        case let .setConfiguration(configuration):
            newState.configuration = configuration
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
    // swiftlint:enable cyclomatic_complexity
    
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

    // MARK: - actions
    func load() -> Observable<Mutation> {
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
    
    func refresh() -> Observable<Mutation> {
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
    
    func loadMore() -> Observable<Mutation> {
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
    
    func reload() -> Observable<Mutation> {
        self.load()
    }
    
    func update() -> Observable<Mutation> {
        .empty()
    }
    
    func execute(_ value: Any?, _ active: Bool, _ needLogin: Bool) -> Observable<Mutation> {
        if active {
            guard !self.currentState.isActivating else { return .empty() }
        }
        return .concat([
            .just(.setError(nil)),
            needLogin ? self.loginIfNeed() : .empty(),
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
    func fetchLocal() -> Observable<Mutation> {
        .just(.initial([]))
    }
    
    func requestRemote(_ mode: HiRequestMode, _ page: Int) -> Observable<Mutation> {
        .empty()
    }
    
    // MARK: - active/silent
    func active(_ value: Any?) -> Observable<Mutation> {
        .empty()
    }
    
    func silent(_ value: Any?) -> Observable<Mutation> {
        .empty()
    }
    
    // MARK: - sections
    func append(
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
    
    func convert(contents: [HiContent]) -> [Section] {
        (contents.count == 0 ? [] : contents.map {
            .sectionItems(header: $0.header, items: $0.models.map {
                if let value = ($0 as? BaseModel)?.data as? SectionItemElement {
                    return value.sectionItem($0)
                }
//                if let user = $0 as? User {
//                    switch user.style {
//                    case .plain: return .userPlain(.init($0))
//                    case .basic: return .userBasic(.init($0))
//                    case .detail: return .userDetail(.init($0))
//                    }
//                }
//                if let repo = $0 as? Repo {
//                    switch repo.style {
//                    case .plain, .basic: return .repoBasic(.init($0))
//                    case .detail: return .repoDetail(.init($0))
//                    }
//                }
//                if let content = $0 as? Content {
//                    if content.isReadme {
//                        return .readmeContent(.init($0))
//                    }
//                    return content.children.count == 0 ? .dirSingle(.init($0)) : .dirMultiple(.init($0))
//                }
//                if $0 is URLScheme {
//                    return .urlScheme(.init($0))
//                }
//                if $0 is Event {
//                    return .event(.init($0))
//                }
//                if $0 is Issue {
//                    return .issue(.init($0))
//                }
//                if $0 is Language {
//                    return .language(.init($0))
//                }
//                if $0 is Degree {
//                    return .degree(.init($0))
//                }
//                if $0 is Branch {
//                    return .branch(.init($0))
//                }
//                if $0 is Pull {
//                    return .pull(.init($0))
//                }
                return .label(.init($0))
            })
        })
    }
    
    // MARK: - other
    func loginIfNeed() -> Observable<Mutation> {
        .create { [weak self] observer -> Disposable in
            guard let `self` = self else { fatalError() }
            if self.currentState.user?.isValid ?? false {
                observer.onCompleted()
                return Disposables.create { }
            }
            return self.navigator.rxLogin()
                .map { Mutation.setUser($0 as? User) }
                .subscribe(observer)
        }
    }

}

extension ListViewReactor.Action {
    
    static func isLoad(_ action: ListViewReactor.Action) -> Bool {
        if case .load = action {
            return true
        }
        return false
    }
    
}
// swiftlint:enable type_body_length
