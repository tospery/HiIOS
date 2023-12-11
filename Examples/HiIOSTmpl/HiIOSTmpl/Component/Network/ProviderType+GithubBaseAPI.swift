//
//  ProviderType+GithubBaseAPI.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import HiIOS

extension ProviderType {
    
    // MARK: 登录/注册
    /// 用户登录
    func login(token: String) -> Single<User> {
        networking.requestObject(
            MultiTarget.init(
                GithubBaseAPI.login(token: token)
            ),
            type: User.self
        )
    }

    // MARK: 其他
    /// 用户信息
    /// - API: https://docs.github.com/en/rest/reference/users#get-a-user
    /// - Demo: https://api.github.com/users/ReactiveX
    func user(username: String) -> Single<User> {
        networking.requestObject(
            MultiTarget.init(
                GithubBaseAPI.user(username: username)
            ),
            type: User.self
        )
    }
    
    /// 用户事件
    func userEvents(username: String, page: Int) -> Single<[Event]> {
        networking.requestArray(
            MultiTarget.init(
                GithubBaseAPI.userEvents(username: username, page: page)
            ),
            type: Event.self
        )
    }
    
}
