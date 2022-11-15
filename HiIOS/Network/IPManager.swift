//
//  IPManager.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import Foundation
import RxSwift
import RxRelay
import Alamofire

public let ipSubject = BehaviorRelay<String?>.init(value: nil)

final public class IPManager {
    
    var disposeBag = DisposeBag()
    public static let shared = IPManager()
    
    init() {
        
    }
    
    deinit {
    }
    
    public func start() {
        reachSubject.asObservable()
            .filter { $0 != .unknown }
            .flatMap { _ in self.request() }
            .subscribe(onNext: { ip in
                ipSubject.accept(ip)
            }).disposed(by: self.disposeBag)
    }
    
    func request() -> Observable<String> {
        return self.request(urlString: "https://api.ipify.org").catch { [weak self] _ in
            guard let `self` = self else { return .empty() }
            return self.request(urlString: "https://api.myip.la")
        }.do(onNext: { ip in
            logger.print("本机IP: \(ip)", module: .hiIOS)
        }, onError: { error in
            logger.print("本机IP: \(error)", module: .hiIOS)
        })
    }
    
    func request(urlString: String) -> Observable<String> {
        Observable<String>.create { observer in
            AF.request(urlString, requestModifier: { $0.timeoutInterval = 2 })
                .responseString { response in
                    if let string = response.value, !string.isEmpty {
                        observer.onNext(string)
                        observer.onCompleted()
                    } else {
                        observer.onError(response.error ?? HiError.unknown)
                    }
                }
            return Disposables.create { }
        }
    }

}
