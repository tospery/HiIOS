//
//  Networking.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Alamofire
import HiIOS

let networking = Networking(
    provider: MoyaProvider<MultiTarget>(
        endpointClosure: Networking.endpointClosure,
        requestClosure: Networking.requestClosure,
        stubClosure: Networking.stubClosure,
        callbackQueue: Networking.callbackQueue,
        session: Networking.session,
        plugins: Networking.plugins,
        trackInflights: Networking.trackInflights
    )
)

struct Networking: NetworkingType {

    typealias Target = MultiTarget
    let provider: MoyaProvider<MultiTarget>
    
    static var session: Alamofire.Session {
        let manager = ServerTrustManager.init(
            allHostsMustBeEvaluated: false,
            evaluators: [
                "gtrend.yapie.me": DisabledTrustEvaluator.init()
            ]
        )
        return Alamofire.Session(serverTrustManager: manager)
    }
    
    static var plugins: [PluginType] {
        var plugins: [PluginType] = []
        let logger = HiLoggerPlugin.init()
#if DEBUG
        logger.configuration.logOptions = [.requestBody, .successResponseBody, .errorResponseBody]
#else
        logger.configuration.logOptions = [.requestBody]
#endif
        logger.configuration.output = output
        plugins.append(logger)
        return plugins
    }
    
    static func output(target: TargetType, items: [String]) {
        for item in items {
            log(item, module: .restful)
        }
    }
    
    func request(_ target: Target) -> Single<Moya.Response> {
        self.provider.rx.request(target)
            .filterSuccessfulStatusCodes()
            .catch { Single<Moya.Response>.error($0.asHiError) }
    }
    
}
