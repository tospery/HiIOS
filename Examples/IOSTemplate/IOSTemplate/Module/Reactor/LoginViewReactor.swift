//
//  LoginViewReactor.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import Rswift
import HiIOS

class LoginViewReactor: ScrollViewReactor, ReactorKit.Reactor {

    enum Action {
        case load
        case login
        case username(String?)
        case password(String?)
    }

    enum Mutation {
        case setLoading(Bool)
        case setActivating(Bool)
        case setError(Error?)
        case setTitle(String?)
        case setUser(User?)
        case setConfiguration(Configuration)
        case setUsername(String?)
        case setPassword(String?)
    }

    struct State {
        var isLoading = false
        var isActivating = false
        var error: Error?
        var title: String?
        var user: User?
        var configuration = Configuration.current!
        var username: String?
        var password: String?
        var sections = [Section].init()
    }

    var initialState = State()

    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
        self.initialState = State(
            title: self.title ?? R.string.localizable.login()
        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load:
            return .empty()
        case let .username(username):
            return .just(.setUsername(username))
        case let .password(password):
            return .just(.setPassword(password))
        case .login:
            return .concat([
                .just(.setError(nil)),
                .just(.setActivating(true)),
                self.login().map(Mutation.setUser),
                .just(.setActivating(false))
            ]).catch {
                .concat([
                    .just(.setError($0)),
                    .just(.setActivating(false))
                ])
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        case let .setActivating(isActivating):
            newState.isActivating = isActivating
        case let .setError(error):
            newState.error = error
        case let .setTitle(title):
            newState.title = title
        case let .setUser(user):
            newState.user = user
        case let .setConfiguration(configuration):
            newState.configuration = configuration
        case let .setUsername(username):
            newState.username = username
        case let .setPassword(password):
            newState.password = password
        }
        return newState
    }
    
    func transform(action: Observable<Action>) -> Observable<Action> {
        action
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        .merge(
            mutation,
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

    func login() -> Observable<User> {
        .create { [weak self] observer -> Disposable in
            guard let `self` = self else { fatalError() }
            guard let username = self.currentState.username, !username.isEmpty,
                  let password = self.currentState.password, !password.isEmpty else {
                observer.onError(APPError.login(nil))
                return Disposables.create { }
            }
            return self.provider.login(username: username, password: password)
                .asObservable()
                .subscribe(observer)
        }
    }
    
}
