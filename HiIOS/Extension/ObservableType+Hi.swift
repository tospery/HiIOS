//
//  ObservableType+Hi.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import Foundation
import RxSwift
import ObjectMapper

extension ObservableType {
    
    public func retry(maxAttempts: UInt, delay: RxTimeInterval) -> Observable<Element> {
        self.retry { error in
            error.enumerated().flatMap { (index, error) -> Observable<Int> in
                guard (index + 1) < maxAttempts else { return .error(error) }
                return Observable<Int>.timer(delay, scheduler: MainScheduler.instance)
            }
        }
    }
    
    public func flatMapEmpty() -> Observable<Element> {
        .empty()
    }
    
}
