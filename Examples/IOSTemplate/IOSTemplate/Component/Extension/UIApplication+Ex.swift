//
//  UIApplication+Ex.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
//

import Foundation
import HiIOS
import SwifterSwift

extension UIApplication {

    var channel: Int {
        switch self.inferredEnvironment {
        case .debug: return 1
        case .testFlight: return 2
        case .appStore: return 3
        }
    }
    
    @objc var myBaseApiUrl: String {
        return "https://api.iostemplate.com"
    }

    @objc var myBaseWebUrl: String {
        return "https://m.iostemplate.com"
    }

}

extension UIApplication.Environment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .debug: return "Debug"
        case .testFlight: return "TestFlight"
        case .appStore: return "AppStore"
        }
    }
}
