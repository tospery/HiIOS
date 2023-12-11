//
//  Router+Page.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import URLNavigator
import HiIOS

extension Router {
    
    public func page(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        navigator.register(self.urlPattern(host: .event)) { url, values, context in
            EventViewController(navigator, EventViewReactor(provider, self.parameters(url, values, context)))
        }
        navigator.register(self.urlPattern(host: .favorite)) { url, values, context in
            FavoriteViewController(navigator, FavoriteViewReactor(provider, self.parameters(url, values, context)))
        }
        navigator.register(self.urlPattern(host: .personal)) { url, values, context in
            PersonalViewController(navigator, PersonalViewReactor(provider, self.parameters(url, values, context)))
        }
//        navigator.register(self.urlPattern(host: .about)) { url, values, context in
//            AboutViewController(navigator, AboutViewReactor(provider, self.parameters(url, values, context)))
//        }
//        navigator.register(self.urlPattern(host: .test)) { url, values, context in
//            TestViewController(navigator, TestViewReactor(provider, self.parameters(url, values, context)))
//        }
    }
    
}
