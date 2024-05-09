//
//  ObservableType+Frame.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import Foundation
import RxSwift
import Moya
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

public extension ObservableType where Element == Response {

    func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(try response.mapObject(type, context: context))
        }
    }

    func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<[T]> {
        return flatMap { response -> Observable<[T]> in
            return Observable.just(try response.mapArray(type, context: context))
        }
    }

    func mapObject<T: BaseMappable>(_ type: T.Type, atKeyPath keyPath: String, context: MapContext? = nil) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(try response.mapObject(T.self, atKeyPath: keyPath, context: context))
        }
    }

    func mapArray<T: BaseMappable>(_ type: T.Type, atKeyPath keyPath: String, context: MapContext? = nil) -> Observable<[T]> {
        return flatMap { response -> Observable<[T]> in
            return Observable.just(try response.mapArray(T.self, atKeyPath: keyPath, context: context))
        }
    }

}

public extension ObservableType where Element == Response {

    func mapObject<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(try response.mapObject(type, context: context))
        }
    }

    func mapArray<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) -> Observable<[T]> {
        return flatMap { response -> Observable<[T]> in
            return Observable.just(try response.mapArray(type, context: context))
        }
    }

    func mapObject<T: ImmutableMappable>(_ type: T.Type, atKeyPath keyPath: String, context: MapContext? = nil) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(try response.mapObject(T.self, atKeyPath: keyPath, context: context))
        }
    }

    func mapArray<T: ImmutableMappable>(_ type: T.Type, atKeyPath keyPath: String, context: MapContext? = nil) -> Observable<[T]> {
        return flatMap { response -> Observable<[T]> in
            return Observable.just(try response.mapArray(T.self, atKeyPath: keyPath, context: context))
        }
    }

}

