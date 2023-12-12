//
//  RepoItem.swift
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

class RepoItem: BaseCollectionItem, ReactorKit.Reactor {

    typealias Action = NoAction
    
    enum Mutation {
        case setName(NSAttributedString?)
    }

    struct State {
        var desc: String?
        var name: NSAttributedString?
        var lang: NSAttributedString?
        var stars: NSAttributedString?
        var forks: NSAttributedString?
        var avatar: ImageSource?
    }

    var initialState = State()

    required public init(_ model: ModelType) {
        super.init(model)
        guard let repo = model as? Repo else { return }
        self.initialState = State(
            desc: repo.desc ?? R.string(preferredLanguages: myLangs).localizable.noneDesc(),
            name: repo.fullnameAttributedText,
            lang: repo.languageAttributedText,
            stars: repo.starsAttributedText,
            forks: repo.forksAttributedText,
            avatar: repo.owner.avatar?.url
        )
    }
        
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setName(name):
            newState.name = name
        }
        return newState
    }

    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        .merge(
           mutation,
           themeService.typeStream.skip(1)
            .map { [weak self] _ -> NSAttributedString? in
                guard let `self` = self else { return nil }
                guard let repo = self.model as? Repo else { return nil }
                return repo.fullnameAttributedText
            }
            .map(Mutation.setName)
       )
    }

}
