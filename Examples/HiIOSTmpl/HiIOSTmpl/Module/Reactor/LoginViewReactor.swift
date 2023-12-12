//
//  LoginViewReactor.swift
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

class LoginViewReactor: ScrollViewReactor, ReactorKit.Reactor {

    enum Action {
        case login
    }

    enum Mutation {
        case setActivating(Bool)
        case setError(Error?)
        case setTitle(String?)
        case setUser(User?)
        case setConfiguration(Configuration)
    }

    struct State {
        var isActivating = false
        var error: Error?
        var title: String?
        var user: User?
        var configuration = Configuration.current!
    }

    var initialState = State()

    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
//        self.initialState = State(
//            title: self.title ?? R.string.localizable.login(
//                preferredLanguages: myLangs
//            )
//        )
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .login:
            return .concat([
                .just(.setError(nil)),
                .just(.setActivating(true)),
                self.login().map(Mutation.setUser),
                .just(.setActivating(false))
            ]).catch {
                Observable.concat([
                    .just(.setError($0)),
                    .just(.setActivating(false))
                ])
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
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
//            var key = self.currentState.accessToken?.accessToken
//            if key?.isEmpty ?? true {
//                key = self.currentState.configuration.privateKey
//            }
//            guard let token = key, !token.isEmpty else {
//                observer.onError(APPError.login(nil))
//                return Disposables.create { }
//            }
            return self.provider.login(token: "")
                .asObservable()
                .subscribe(observer)
        }
    }
    
}
