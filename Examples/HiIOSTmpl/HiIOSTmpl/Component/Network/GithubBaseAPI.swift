//
//  GithubBaseAPI.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import SwifterSwift
import Moya
import HiIOS

enum GithubBaseAPI {
    case login(token: String)
    case user(username: String)
    case userEvents(username: String, page: Int)
}

extension GithubBaseAPI: TargetType {

    var baseURL: URL {
        return UIApplication.shared.baseApiUrl.url!
    }

    var path: String {
        switch self {
        case .login: return "/user"
        case let .userEvents(username, _): return "/users/\(username)/received_events"
        case let .user(username): return "/users/\(username)"
        }
    }

    var method: Moya.Method {
        .get
    }

    var headers: [String: String]? {
        switch self {
        case let .login(token):
            return [Parameter.authorization: "token \(token)"]
        default:
//            if let token = AccessToken.current?.accessToken {
//                return [Parameter.authorization: "token \(token)"]
//            }
            return nil
        }
    }

    var task: Task {
        var parameters = envParameters
        var encoding: ParameterEncoding = URLEncoding.default
        switch self {
        case .userEvents(_, let page):
            parameters[Parameter.pageIndex] = page
            parameters[Parameter.pageSize] = UIApplication.shared.pageSize
        default:
            return .requestPlain
        }
        return .requestParameters(parameters: parameters, encoding: encoding)
    }

    var validationType: ValidationType { .none }

    var sampleData: Data {
        Data.init()
    }

}
