//
//  Runtime.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import UIKit
import HiCore

import HiTheme
import HiNav

public protocol RuntimeCompatible {
    func myWork()
}

final public class Runtime {

    public static var shared = Runtime()
    
    public init() {
    }
    
    public func work() {
        if let compatible = self as? RuntimeCompatible {
            compatible.myWork()
        } else {
            self.basic()
        }
    }
    
    public func basic() {
        ExchangeImplementations(UIViewController.self, #selector(UIViewController.present(_:animated:completion:)), #selector(UIViewController.hi_present(_:animated:completion:)))
    }
    
}
