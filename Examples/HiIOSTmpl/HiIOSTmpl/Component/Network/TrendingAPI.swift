//
//  TrendingAPI.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import SwifterSwift
import Moya
import HiIOS

enum TrendingAPI {
    case trendingUsers
    case trendingRepos
}

extension TrendingAPI: TargetType {

    var baseURL: URL {
        return UIApplication.shared.baseTrendingUrl.url!
    }

    var path: String {
        switch self {
        case .trendingUsers: return "/developers"
        case .trendingRepos: return "/repositories"
        }
    }

    var method: Moya.Method { .get }

    var headers: [String: String]? { nil }

    var task: Task {
        let parameters = envParameters
        let encoding: ParameterEncoding = URLEncoding.default
//        switch self {
//        case .trendingUsers(let language, let since),
//             .trendingRepos(let language, let since):
//            parameters[Parameter.language] = language?.urlParam
//            parameters[Parameter.since] = since?.rawValue
//        default:
//            break
//        }
        return .requestParameters(parameters: parameters, encoding: encoding)
    }

    var validationType: ValidationType { .none }

    var sampleData: Data { Data.init() }

}
