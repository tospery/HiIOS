//
//  Error.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
//

import Foundation
import HiIOS
import ReusableKit_Hi
import ObjectMapper_Hi
import RxOptional
import RxSwiftExt
import NSObject_Rx
import RxDataSources
import RxViewController
import RxTheme

enum APPError: Error {
    case login(String?)
}

extension APPError: CustomNSError {
    var errorCode: Int {
        switch self {
        case .login: return 1
        }
    }
}

extension APPError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .login(message): return message ?? R.string.localizable.errorLogin()
        }
    }
}

extension APPError: HiErrorCompatible {
    public var hiError: HiError {
        .app(self.errorCode, self.errorDescription, nil)
    }
}

extension RxOptionalError: HiErrorCompatible {
    public var hiError: HiError {
        switch self {
        case .emptyOccupiable: return .dataIsEmpty
        case .foundNilWhileUnwrappingOptional: return .dataInvalid
        }
    }
}
