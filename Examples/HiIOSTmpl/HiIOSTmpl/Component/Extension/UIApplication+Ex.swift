//
//  UIApplication+Ex.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/4.
//

import Foundation
import SwifterSwift
import HiIOS

extension UIApplication {

    var channel: Int {
        switch self.inferredEnvironment {
        case .debug: return 1
        case .testFlight: return 2
        case .appStore: return 3
        }
    }
    
    var baseTrendingUrl: String { "https://gtrend.yapie.me" }
    var baseGithubUrl: String { "https://github.com" }
    @objc var myBaseApiUrl: String { "https://api.github.com" }
    @objc var myBaseWebUrl: String { "https://github.com" }
    
    @objc var myPageSize: Int { 30 }

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
