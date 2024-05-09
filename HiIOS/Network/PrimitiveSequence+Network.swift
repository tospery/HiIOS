//
//  PrimitiveSequence+Network.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import Foundation
import RxSwift
import Moya
import ObjectMapper

public extension PrimitiveSequence where Trait == SingleTrait, Element == Response {

    func mapObject<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<T> {
        return flatMap { response -> Single<T> in
                    return Single.just(try response.mapObject(type, context: context))
                }
    }

    func mapArray<T: BaseMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<[T]> {
        return flatMap { response -> Single<[T]> in
                    return Single.just(try response.mapArray(type, context: context))
                }
    }

    func mapObject<T: BaseMappable>(_ type: T.Type, atKeyPath keyPath: String, context: MapContext? = nil) -> Single<T> {
        return flatMap { response -> Single<T> in
          return Single.just(try response.mapObject(type, atKeyPath: keyPath, context: context))
                }
    }

    func mapArray<T: BaseMappable>(_ type: T.Type, atKeyPath keyPath: String, context: MapContext? = nil) -> Single<[T]> {
        return flatMap { response -> Single<[T]> in
                    return Single.just(try response.mapArray(type, atKeyPath: keyPath, context: context))
                }
    }

}


public extension PrimitiveSequence where Trait == SingleTrait, Element == Response {

    func mapObject<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<T> {
        return flatMap { response -> Single<T> in
                    return Single.just(try response.mapObject(type, context: context))
                }
    }

    func mapArray<T: ImmutableMappable>(_ type: T.Type, context: MapContext? = nil) -> Single<[T]> {
        return flatMap { response -> Single<[T]> in
                    return Single.just(try response.mapArray(type, context: context))
                }
    }

    func mapObject<T: ImmutableMappable>(_ type: T.Type, atKeyPath keyPath: String, context: MapContext? = nil) -> Single<T> {
        return flatMap { response -> Single<T> in
                    return Single.just(try response.mapObject(type, atKeyPath: keyPath, context: context))
                }
    }

    func mapArray<T: ImmutableMappable>(_ type: T.Type, atKeyPath keyPath: String, context: MapContext? = nil) -> Single<[T]> {
        return flatMap { response -> Single<[T]> in
                    return Single.just(try response.mapArray(type, atKeyPath: keyPath, context: context))
                }
    }

}

