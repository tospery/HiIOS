//
//  NavigationController.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import UIKit

open class NavigationController: UINavigationController {
        
    open override var shouldAutorotate: Bool {
        return (self.topViewController?.shouldAutorotate)!
    }
        
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (self.topViewController?.supportedInterfaceOrientations)!
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return (self.topViewController?.preferredStatusBarStyle)!
    }

}
