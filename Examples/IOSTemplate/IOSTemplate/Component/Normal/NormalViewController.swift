//
//  NormalViewController.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2022/10/3.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import Rswift
import HiIOS
import ReusableKit_Hi
import ObjectMapper_Hi
import RxDataSources
import RxGesture

class NormalViewController: HiIOS.CollectionViewController, ReactorKit.View {
    
    struct Reusable {
        static let simpleCell = ReusableCell<SimpleCell>()
        static let headerView = ReusableView<CollectionHeaderView>()
        static let footerView = ReusableView<CollectionFooterView>()
    }
    
    lazy var dataSource: RxCollectionViewSectionedReloadDataSource<Section> = {
        return .init(
            configureCell: { [weak self] _, collectionView, indexPath, sectionItem in
                guard let `self` = self else { fatalError() }
                switch sectionItem {
                case let .simple(item):
                    let cell = collectionView.dequeue(Reusable.simpleCell, for: indexPath)
                    item.parent = self.reactor
                    cell.reactor = item
                    return cell
                }
            },
            configureSupplementaryView: { [weak self] _, collectionView, kind, indexPath in
                guard let `self` = self else { return collectionView.emptyView(for: indexPath, kind: kind) }
                switch kind {
                case UICollectionView.elementKindSectionHeader:
                    return self.headerView(collectionView, for: indexPath)
                case UICollectionView.elementKindSectionFooter:
                    let footer = collectionView.dequeue(Reusable.footerView, kind: kind, for: indexPath)
                    footer.theme.backgroundColor = themeService.attribute { $0.lightColor }
                    return footer
                default:
                    return collectionView.emptyView(for: indexPath, kind: kind)
                }
            }
        )
    }()

    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        defer {
            self.reactor = reactor as? NormalViewReactor
        }
        super.init(navigator, reactor)
        self.tabBarItem.title = reactor.title ?? (reactor as? NormalViewReactor)?.currentState.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(Reusable.simpleCell)
        self.collectionView.register(Reusable.headerView, kind: .header)
        self.collectionView.register(Reusable.footerView, kind: .footer)
        self.collectionView.theme.backgroundColor = themeService.attribute { $0.lightColor }
        self.collectionView.rx.itemSelected(dataSource: self.dataSource)
            .subscribeNext(weak: self, type(of: self).tapItem)
            .disposed(by: self.rx.disposeBag)
//        if self.reactor?.host == .article && self.reactor?.path == .list {
//            if self.pagingViewController != nil {
//                self.collectionView.frame = .init(
//                    x: 0,
//                    y: 0,
//                    width: deviceWidth,
//                    height: deviceHeight - navigationContentTopConstant - 50 - tabBarHeight
//                )
//            }
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        if self.reactor?.host == .article && self.reactor?.path == .list {
//            if self.pagingViewController != nil && self.collectionView.height == deviceHeight {
//                self.collectionView.frame = .init(
//                    x: 0,
//                    y: 0,
//                    width: deviceWidth,
//                    height: deviceHeight - navigationContentTopConstant - 50 - tabBarHeight
//                )
//            }
//        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.reactor?.host == .personal {
            return statusBarService.value.reversed
        }
        return super.preferredStatusBarStyle
    }

    func bind(reactor: NormalViewReactor) {
        super.bind(reactor: reactor)
        self.toAction(reactor: reactor)
        self.fromState(reactor: reactor)
    }
    
    func toAction(reactor: NormalViewReactor) {
        self.rx.load.map { Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        self.rx.refresh.map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        self.rx.loadMore.map { Reactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    // swiftlint:disable function_body_length
    func fromState(reactor: NormalViewReactor) {
        reactor.state.map { $0.title }
            .distinctUntilChanged()
            .bind(to: self.rx.title)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: self.rx.loading)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .bind(to: self.rx.refreshing)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.isLoadingMore }
            .distinctUntilChanged()
            .bind(to: self.rx.loadingMore)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.isActivating }
            .distinctUntilChanged()
            .bind(to: self.rx.activating)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.noMoreData }
            .distinctUntilChanged()
            .bind(to: self.rx.noMoreData)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.error }
            .distinctUntilChanged({ $0?.asHiError == $1?.asHiError })
            .bind(to: self.rx.error)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.user }
            .distinctUntilChanged()
            .skip(1)
            .subscribeNext(weak: self, type(of: self).handleUser)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.configuration }
            .distinctUntilChanged()
            .skip(1)
            .subscribeNext(weak: self, type(of: self).handleConfiguration)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.target }
            .distinctUntilChanged()
            .filterNil()
            .subscribeNext(weak: self, type(of: self).handleTarget)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.sections }
            .distinctUntilChanged()
            .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }
    // swiftlint:enable function_body_length
    
    // MARK: - header/footer
    func headerView(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeue(
            Reusable.headerView,
            kind: UICollectionView.elementKindSectionHeader,
            for: indexPath
        )
        header.theme.backgroundColor = themeService.attribute { $0.lightColor }
        return header
    }
    
    // MARK: - handle
    func handleUser(user: User?) {
        log("handleUser -> 更新用户(\(self.reactor?.host ?? ""), \(self.reactor?.path ?? ""))")
        MainScheduler.asyncInstance.schedule(()) { _ -> Disposable in
            User.update(user, reactive: true)
            return Disposables.create {}
        }.disposed(by: self.disposeBag)
    }
    
    func handleConfiguration(configuration: Configuration) {
        log("handleConfiguration -> 更新配置(\(self.reactor?.host ?? ""), \(self.reactor?.path ?? ""))")
        MainScheduler.asyncInstance.schedule(()) { _ -> Disposable in
            Subjection.update(Configuration.self, configuration, true)
            return Disposables.create {}
        }.disposed(by: self.disposeBag)
    }
    
    func handleTarget(target: String) {
        self.navigator.forward(target)
    }
    
    // MARK: - tap
    func tapItem(sectionItem: SectionItem) {
//        switch sectionItem {
//        case let .simple(item):
//            guard let target = (item.model as? Simple)?.target, target.isNotEmpty else { return }
//            self.navigator.forward(target)
//        }
    }

    func tapUser(_: Void? = nil) {
//        if self.reactor?.currentState.user?.isValid ?? false {
//            self.navigator.forward(Router.shared.urlString(host: .profile, parameters: [
//                Parameter.title: self.reactor?.currentState.user?.username ?? ""
//            ]))
//            return
//        }
//        self.navigator.login()
    }
    
}

extension NormalViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.sectionWidth(at: indexPath.section)
        switch self.dataSource[indexPath] {
        case let .simple(item): return Reusable.simpleCell.class.size(width: width, item: item)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        .zero
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        .zero
    }

}
