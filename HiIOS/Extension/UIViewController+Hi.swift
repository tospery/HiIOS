//
//  UIViewController+Hi.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import SwifterSwift

public extension UIViewController {
    
    struct RuntimeKey {
        static let automaticallySetModalPresentationStyleKey = UnsafeRawPointer.init(bitPattern: "automaticallySetModalPresentationStyleKey".hashValue)
    }
    
    var previous: UIViewController? {
        guard let viewControllers = self.navigationController?.viewControllers else { return nil }
        if let index = viewControllers.firstIndex(of: self), index > 0 {
            return viewControllers[index - 1]
        }
        return nil
    }
    
    var isPresented: Bool {
        var viewController = self
        if let navigationController = self.navigationController {
            if navigationController.viewControllers.first != self {
                return false
            }
            viewController = navigationController
        }
        let result = viewController.presentingViewController?.presentedViewController == viewController
        return result
    }
    
    var automaticallySetModalPresentationStyle: Bool? {
        get {
            objc_getAssociatedObject(self, RuntimeKey.automaticallySetModalPresentationStyleKey!) as? Bool
        }
        set {
            objc_setAssociatedObject(self, RuntimeKey.automaticallySetModalPresentationStyleKey!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    @objc func hi_present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if #available(iOS 13.0, *) {
            var need = true
            if let _ = self as? UIImagePickerController {
                need = false
            } else if let _ = self as? UIAlertController {
                need = false
            } else {
                let className = viewControllerToPresent.className
                if className == "PopupDialog" ||
                    className == "SideMenuNavigationController" {
                    need = false
                }
            }
            if need {
                if let auto = self.automaticallySetModalPresentationStyle, auto == false {
                    need = false
                }
            }
            if need {
                viewControllerToPresent.modalPresentationStyle = .fullScreen
            }
        }
        self.hi_present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
}

