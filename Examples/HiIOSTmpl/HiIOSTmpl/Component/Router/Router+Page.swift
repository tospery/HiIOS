//
//  Router+Page.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import URLNavigator_Hi
import HiIOS

extension Router {
    
    public func page(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        navigator.register(self.urlPattern(host: .trending)) { url, values, context in
            TrendingViewController(navigator, TrendingViewReactor(provider, self.parameters(url, values, context)))
        }
        navigator.register(self.urlPattern(host: .favorite)) { url, values, context in
            FavoriteViewController(navigator, FavoriteViewReactor(provider, self.parameters(url, values, context)))
        }
        navigator.register(self.urlPattern(host: .personal)) { url, values, context in
            PersonalViewController(navigator, PersonalViewReactor(provider, self.parameters(url, values, context)))
        }
        // hiiostmpl://user/list?page=&username=&reponame=
        navigator.register(self.urlPattern(host: .user, path: .list)) { url, values, context in
            UserListViewController(navigator, UserListViewReactor(provider, self.parameters(url, values, context)))
        }
        // hiiostmpl://repo/list?page=&username=&reponame=
        navigator.register(self.urlPattern(host: .repo, path: .list)) { url, values, context in
            RepoListViewController(navigator, RepoListViewReactor(provider, self.parameters(url, values, context)))
        }
        // hiiostmpl://user/<username>
        navigator.register(self.urlPattern(host: .user, placeholder: "[username]")) { url, values, context in
            UserViewController(navigator, UserViewReactor(provider, self.parameters(url, values, context)))
        }
        // hiiostmpl://repo/<username>/<reponame>
        navigator.register(self.urlPattern(host: .repo, placeholder: "[username]/[reponame]")) { url, values, context in
            RepoViewController(navigator, RepoViewReactor(provider, self.parameters(url, values, context)))
        }
        navigator.register(self.urlPattern(host: .options)) { url, values, context in
            OptionsViewController(navigator, OptionsViewReactor(provider, self.parameters(url, values, context)))
        }
        navigator.register(self.urlPattern(host: .about)) { url, values, context in
            AboutViewController(navigator, AboutViewReactor(provider, self.parameters(url, values, context)))
        }
        navigator.register(self.urlPattern(host: .settings)) { url, values, context in
            TestViewController(navigator, TestViewReactor(provider, self.parameters(url, values, context)))
        }
        navigator.register(self.urlPattern(host: .test)) { url, values, context in
            TestViewController(navigator, TestViewReactor(provider, self.parameters(url, values, context)))
        }
    }
    
}
