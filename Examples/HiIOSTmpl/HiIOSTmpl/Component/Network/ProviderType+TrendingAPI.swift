//
//  ProviderType+TrendingAPI.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import HiIOS

extension ProviderType {
    
    // MARK: - TrendingAPI
    /// 仓库推荐: https://gtrend.yapie.me/repositories
    func trendingRepos() -> Single<[Repo]> {
        return networking.requestArray(
            MultiTarget.init(
                TrendingAPI.trendingRepos
            ),
            type: Repo.self
        )
    }
    
    /// 开发者推荐: https://gtrend.yapie.me/developers
    func trendingUsers() -> Single<[User]> {
        networking.requestArray(
            MultiTarget.init(
                TrendingAPI.trendingUsers
            ),
            type: User.self
        )
    }
    
}
