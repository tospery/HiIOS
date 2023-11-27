//
//  IOSTemplateAPI.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
//

import Foundation
import Moya
import HiIOS

enum IOSTemplateAPI {
    case login(username: String, password: String)
}

extension IOSTemplateAPI: TargetType {

    var baseURL: URL {
        return UIApplication.shared.baseApiUrl.url!
    }

    var path: String {
        switch self {
        case .login: return "/login"
        }
    }

    var method: Moya.Method { .get }

    var headers: [String: String]? { nil }

    var task: Task {
        var parameters = envParameters
        var encoding: ParameterEncoding = URLEncoding.default
        switch self {
        case let .login(username, password):
            parameters[Parameter.username] = username
            parameters[Parameter.password] = password
            encoding = JSONEncoding.default
        }
        return .requestParameters(parameters: parameters, encoding: encoding)
    }

    var validationType: ValidationType { .none }

    var sampleData: Data { Data.init() }

}
