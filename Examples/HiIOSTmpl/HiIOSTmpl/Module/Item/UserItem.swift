//
//  UserItem.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/13.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RswiftResources
import BonMot
import HiIOS

class UserItem: BaseCollectionItem, ReactorKit.Reactor {

    typealias Action = NoAction
    typealias Mutation = NoMutation

    struct State {
        var user: String?
        var desc: String?
        var repo: NSAttributedString?
        var avatar: ImageSource?
    }

    var initialState = State()

    required public init(_ model: ModelType) {
        super.init(model)
        guard let user = model as? User else { return }
        self.initialState = State(
            user: user.fullname,
            desc: user.repo?.desc ?? R.string(preferredLanguages: myLangs).localizable.noneDesc(),
            repo: user.repoAttributedText,
            avatar: user.avatar?.url
        )
    }
    
}
