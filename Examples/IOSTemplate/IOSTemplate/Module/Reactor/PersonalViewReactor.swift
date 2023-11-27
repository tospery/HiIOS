//
//  PersonalViewReactor.swift
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

class PersonalViewReactor: NormalViewReactor {
    
    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
        self.initialState = State(
            title: self.title ?? R.string.localizable.mine()
        )
    }
    
//    override func loadData(_ page: Int) -> Observable<[SectionData]> {
//        .create { [weak self] observer -> Disposable in
//            guard let `self` = self else { fatalError() }
//            var models = [ModelType].init()
//            if let user = self.currentState.user, user.isValid {
//                models.append(Simple.init(height: 5))
//                models.append(BaseModel.init(SectionItemValue.milestone))
//                models.append(Simple.init(height: 10))
//                models.append(contentsOf: [
//                    Simple.init(
//                        id: SimpleId.company.rawValue,
//                        icon: "ic_company",
//                        title: user.company ?? R.string.localizable.noDescription(),
//                        indicated: false
//                    ),
//                    Simple.init(
//                        id: SimpleId.location.rawValue,
//                        icon: "ic_location",
//                        title: user.location ?? R.string.localizable.noDescription(),
//                        indicated: false
//                    ),
//                    Simple.init(
//                        id: SimpleId.email.rawValue,
//                        icon: "ic_email",
//                        title: user.email ?? R.string.localizable.noDescription(),
//                        indicated: false
//                    ),
//                    Simple.init(
//                        id: SimpleId.blog.rawValue,
//                        icon: "ic_blog",
//                        title: user.blog ?? R.string.localizable.noDescription(),
//                        divided: false
//                    )
//                ])
//                models.append(Simple.init(height: 15))
//            }
//            if let simples = Simple.cachedArray(page: self.host) {
//                models.append(contentsOf: simples)
//            }
//            observer.onNext([(header: nil, models: models)])
//            observer.onCompleted()
//            return Disposables.create { }
//        }
//    }

}
