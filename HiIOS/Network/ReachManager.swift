//
//  ReachManager.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import Foundation
import RxSwift
import RxRelay
import Alamofire
 
public let reachSubject = BehaviorRelay<NetworkReachabilityManager.NetworkReachabilityStatus>.init(value: .unknown)
 
final public class ReachManager {
    
    let network = NetworkReachabilityManager.default
    public static let shared = ReachManager()

    init() {
    }
    
    deinit {
        self.network?.stopListening()
    }
    
    func start() {
        self.network?.startListening(onUpdatePerforming: { status in
            logger.print("网络状态: \(status)", module: .hiIOS)
            reachSubject.accept(status)
        })
    }

}

extension NetworkReachabilityManager.NetworkReachabilityStatus {
    
    public var isCellular: Bool { self == .reachable(.cellular) }
    public var isWifi: Bool { self == .reachable(.ethernetOrWiFi) }
    public var isReachable: Bool { self != .notReachable && self != .unknown }
    
}


extension NetworkReachabilityManager.NetworkReachabilityStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return NSLocalizedString("Network.Reach.Unknow", value: "", comment: "") // 未知网络
        case .notReachable:
            return NSLocalizedString("Network.Reach.NotReachable", value: "", comment: "") // 网络不可达
        case let .reachable(type):
            return type == .cellular ? "cellular" : "wifi"
        }
     }
}
