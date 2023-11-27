//
//  ListViewController.swift
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

// swiftlint:disable type_body_length file_length
class ListViewController: HiIOS.CollectionViewController, ReactorKit.View {
    
    struct Reusable {
        static let labelCell = ReusableCell<LabelCell>()
        static let baseHeader = ReusableView<BaseCollectionHeader>()
        static let baseFooter = ReusableView<BaseCollectionFooter>()
    }
    
//    lazy var dataSource: RxCollectionViewSectionedReloadDataSource<Section> = {
//        return .init(
//            configureCell: { [weak self] dataSource, collectionView, indexPath, sectionItem in
//                guard let `self` = self else { return collectionView.emptyCell(for: indexPath)}
//                return self.cell(dataSource, collectionView, indexPath, sectionItem)
//            },
//            configureSupplementaryView: { [weak self] _, collectionView, kind, indexPath in
//                guard let `self` = self else { return collectionView.emptyView(for: indexPath, kind: kind) }
//                switch kind {
//                case UICollectionView.elementKindSectionHeader:
//                    return self.header(collectionView, for: indexPath)
//                case UICollectionView.elementKindSectionFooter:
//                    let footer = collectionView.dequeue(Reusable.baseFooter, kind: kind, for: indexPath)
//                    footer.theme.backgroundColor = themeService.attribute { $0.lightColor }
//                    return footer
//                default:
//                    return collectionView.emptyView(for: indexPath, kind: kind)
//                }
//            }
//        )
//    }()
    
    lazy var dataSource: RxCollectionViewSectionedReloadDataSource<Section> = {
        .init { [weak self] dataSource, collectionView, indexPath, sectionItem in
            guard let `self` = self else { return collectionView.emptyCell(for: indexPath)}
            return self.cell(dataSource, collectionView, indexPath, sectionItem)
        } configureSupplementaryView: { [weak self] _, collectionView, kind, indexPath in
            guard let `self` = self else { return collectionView.emptyView(for: indexPath, kind: kind) }
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                return self.header(collectionView, for: indexPath)
            case UICollectionView.elementKindSectionFooter:
                let footer = collectionView.dequeue(Reusable.baseFooter, kind: kind, for: indexPath)
                footer.theme.backgroundColor = themeService.attribute { $0.lightColor }
                return footer
            default:
                return collectionView.emptyView(for: indexPath, kind: kind)
            }
        }
    }()

    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        defer {
            self.reactor = reactor as? ListViewReactor
        }
        super.init(navigator, reactor)
        self.tabBarItem.title = reactor.title ?? (reactor as? ListViewReactor)?.currentState.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(Reusable.labelCell)
        self.collectionView.register(Reusable.baseHeader, kind: .header)
        self.collectionView.register(Reusable.baseFooter, kind: .footer)
        self.collectionView.theme.backgroundColor = themeService.attribute { $0.lightColor }
        self.collectionView.rx.itemSelected(dataSource: self.dataSource)
            .subscribeNext(weak: self, type(of: self).tapItem)
            .disposed(by: self.rx.disposeBag)
    }

    // swiftlint:disable function_body_length
    func bind(reactor: ListViewReactor) {
        super.bind(reactor: reactor)
        // action
        self.rx.load.map { Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        self.rx.viewWillAppear.skip(1).map { _ in Reactor.Action.update }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        self.rx.refresh.map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        self.rx.loadMore.map { Reactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        // state
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
        reactor.state.map { $0.data }
            .distinctUntilChanged { HiIOS.compareAny($0, $1) }
            .skip(1)
            .subscribeNext(weak: self, type(of: self).handleData)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.contents }
            .distinctUntilChanged { HiIOS.compareAny($0, $1) }
            .skip(1)
            .subscribeNext(weak: self, type(of: self).handleContents)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.user }
            .distinctUntilChanged()
            .skip(1)
            .subscribeNext(weak: self, type(of: self).handleUser)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.user?.isValid }
            .distinctUntilChanged()
            .skip(1)
            .subscribeNext(weak: self, type(of: self).handleLogin)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.configuration.localization }
            .distinctUntilChanged()
            .skip(1)
            .subscribeNext(weak: self, type(of: self).handleLocalization)
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
    
    // MARK: - cell/header/footer
    func cell(
        _ dataSource: CollectionViewSectionedDataSource<Section>,
        _ collectionView: UICollectionView,
        _ indexPath: IndexPath,
        _ sectionItem: Section.Item
    ) -> UICollectionViewCell {
        switch sectionItem {
        case let .label(item):
            let cell = collectionView.dequeue(Reusable.labelCell, for: indexPath)
            item.parent = self.reactor
            cell.reactor = item
            cell.rx.click
                .subscribeNext(weak: self, type(of: self).handleTarget)
                .disposed(by: cell.disposeBag)
            return cell
        }
    }
    
    func header(_ collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeue(
            Reusable.baseHeader,
            kind: UICollectionView.elementKindSectionHeader,
            for: indexPath
        )
        header.theme.backgroundColor = themeService.attribute { $0.lightColor }
        return header
    }
    
    // MARK: - handle
    func handleLogin(isLogined: Bool?) {
        log("\(#function), (\(self.reactor?.host ?? ""), \(self.reactor?.path ?? "")): \(isLogined ?? false)")
        MainScheduler.asyncInstance.schedule(()) { [weak self] _ -> Disposable in
            guard let `self` = self else { fatalError() }
            self.reactor?.action.onNext(.reload)
            return Disposables.create {}
        }.disposed(by: self.disposeBag)
    }
    
    func handleLocalization(localization: Localization) {
//        MainScheduler.asyncInstance.schedule(()) { [weak self] _ -> Disposable in
//            guard let `self` = self else { fatalError() }
//            let langs = self.reactor?.currentState.configuration.localization.preferredLanguages
//            let title = self.reactor?.currentState.title?.localized(preferredLanguages: langs)
//            self.reactor?.action.onNext(.title(title))
//            return Disposables.create {}
//        }.disposed(by: self.disposeBag)
    }
    
    func handleUser(user: User?) {
        if User.current == user {
            return
        }
        MainScheduler.asyncInstance.schedule(()) { _ -> Disposable in
            log("handleUser(\(self.reactor?.host ?? ""), \(self.reactor?.path ?? "")) -> 更新用户，准备保存")
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
    
    func handleTarget(target: String?) {
        guard let url = target?.url else { return }
        if url.host == .back {
            let forwardType = url.queryValue(for: Parameter.forwardType)?.int
            let animated = url.queryValue(for: Parameter.animated)?.bool
            let result = url.queryValue(for: Parameter.result)
            let cancel = url.queryValue(for: Parameter.cancel)?.bool
            let message = url.queryValue(for: Parameter.message)
            self.back(
                type: .init(rawValue: forwardType ?? ForwardType.auto.rawValue) ?? .auto,
                animated: animated ?? true,
                result: result,
                cancel: cancel ?? false,
                message: message
            )
            return
        }
        self.navigator.forward(url)
    }
    
    func handleData(data: Any?) {
    }
    
    func handleContents(contents: [HiContent]) {
    }
    
    // MARK: - tap
    func tapItem(sectionItem: SectionItem) {
//        let username = self.reactor?.username ?? ""
//        let reponame = self.reactor?.reponame ?? ""
//        switch sectionItem {
//        case let .label(item):
//            guard let labelInfo = item.model as? LabelInfo else { return }
//            if let target = labelInfo.target, target.isNotEmpty {
//                self.navigator.forward(target)
//                return
//            }
//            if let cellId = CellId.init(rawValue: simple.id) {
//                switch cellId {
//                case .language:
//                    let ref = (self.reactor?.currentState.data as? RepoViewReactor.Data)?.branch?.id
//                    let dft = (self.reactor?.currentState.data as? RepoViewReactor.Data)?.repo?.defaultBranch ?? ""
//                    self.navigator.forward(Router.shared.urlString(host: .dir, parameters: [
//                        Parameter.username: username,
//                        Parameter.reponame: reponame,
//                        Parameter.title: reponame,
//                        Parameter.ref: ref ?? dft
//                    ]))
//                case .issues:
//                    self.navigator.forward(
//                        Router.shared.urlString(host: .page, parameters: [
//                            Parameter.username: username,
//                            Parameter.reponame: reponame,
//                            Parameter.title: R.string.localizable.issues(
//                                preferredLanguages: myLangs
//                            ),
//                            Parameter.pages: Page.stateValues.map { $0.rawValue }.jsonString() ?? ""
//                        ])
//                    )
//                case .pulls:
//                    self.navigator.forward(
//                        Router.shared.urlString(host: .page, parameters: [
//                            Parameter.username: username,
//                            Parameter.reponame: reponame,
//                            Parameter.title: R.string.localizable.pulls(
//                                preferredLanguages: myLangs
//                            ),
//                            Parameter.pages: Page.stateValues.map { $0.rawValue }.jsonString() ?? ""
//                        ])
//                    )
//                case .branches:
//                    guard
//                        let selected = (self.reactor?.currentState.data as? RepoViewReactor.Data)?.branch?.id,
//                        selected.isNotEmpty
//                    else { return }
//                    self.navigator.rxPopup(.branches, context: [
//                        Parameter.username: username,
//                        Parameter.reponame: reponame,
//                        Parameter.selected: selected
//                    ]).subscribe(onNext: { [weak self] result in
//                        guard let `self` = self else { return }
//                        var data = self.reactor?.currentState.data as? RepoViewReactor.Data
//                        data?.branch = result as? Branch
//                        self.reactor?.action.onNext(.data(data))
//                    }).disposed(by: self.disposeBag)
//                case .readme:
//                    guard
//                        let url = (self.reactor?.currentState.data as? RepoViewReactor.Data)?.repo?.htmlUrl,
//                        url.isNotEmpty
//                    else { return }
//                    self.navigator.forward(url, context: [
//                        Parameter.routerForceWeb: true
//                    ])
//                default:
//                    break
//                }
//            }
//        case let .userBasic(item):
//            guard let username = (item.model as? User)?.username else { return }
//            self.navigator.forward(Router.shared.urlString(host: .user, path: username))
//        case let .userPlain(item):
//            guard let username = (item.model as? User)?.username else { return }
//            self.navigator.forward(Router.shared.urlString(host: .user, path: username))
//        case let .repoBasic(item):
//            guard let url = (item.model as? Repo)?.htmlUrl, url.isNotEmpty else { return }
//            self.navigator.forward(url)
//        case let .event(item):
//            guard let event = item.model as? Event else { return }
//            switch event.type {
//            case .create, .delete, .star:
//                guard let name = event.repo?.name, name.isNotEmpty else { return }
//                self.navigator.forward(Router.shared.urlString(host: .repo, path: name))
//            case .pull:
//                guard let url = event.payload?.pull?.htmlUrl else { return }
//                self.navigator.forward(url)
//            case .issueHandle, .issueComment:
//                guard let url = event.payload?.issue?.htmlUrl else { return }
//                self.navigator.forward(url)
//            default:
//                break
//            }
//        case let .issue(item):
//            guard let url = (item.model as? Issue)?.htmlUrl else { return }
//            self.navigator.forward(url)
//        case let .pull(item):
//            guard let url = (item.model as? Pull)?.htmlUrl else { return }
//            self.navigator.forward(url)
//        case let .language(item):
//            guard let language = item.model as? Language else { return }
//            MainScheduler.asyncInstance.schedule(()) { [weak self] _ -> Disposable in
//                guard let `self` = self else { fatalError() }
//                self.reactor?.action.onNext(.execute(value: language, active: false, needLogin: false))
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    self.back()
//                }
//                return Disposables.create {}
//            }.disposed(by: self.disposeBag)
//        case let .degree(item):
//            guard let degree = item.model as? Degree else { return }
//            MainScheduler.asyncInstance.schedule(()) { [weak self] _ -> Disposable in
//                guard let `self` = self else { fatalError() }
//                self.reactor?.action.onNext(.execute(value: degree, active: false, needLogin: false))
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    self.back()
//                }
//                return Disposables.create {}
//            }.disposed(by: self.disposeBag)
//        case let .dirSingle(item):
//            guard let content = item.model as? Content else { return }
//            MainScheduler.asyncInstance.schedule(()) { [weak self] _ -> Disposable in
//                guard let `self` = self else { fatalError() }
//                self.reactor?.action.onNext(.execute(value: content, active: true, needLogin: false))
//                return Disposables.create {}
//            }.disposed(by: self.disposeBag)
//        default:
//            break
//        }
    }
    
    func tapUser(username: String) {
        self.navigator.forward(Router.shared.urlString(host: .user, path: username))
    }
    
    func tapQuery(query: String) {
//        if query.isEmpty {
//            return
//        }
//        var configuration = self.reactor?.currentState.configuration
//        var keywords = configuration?.keywords ?? []
//        keywords.removeFirst { $0 == query }
//        keywords.insert(query, at: 0)
//        configuration?.keywords = keywords
//        Subjection.update(Configuration.self, configuration, true)
//        self.navigator.fPush(
//            Router.shared.urlString(host: .search, parameters: [
//                Parameter.query: query
//            ]),
//            animated: false
//        )
//    }
    
    func tapLogo(_: Void? = nil) {
    }

}

extension ListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.sectionWidth(at: indexPath.section)
        switch self.dataSource[indexPath] {
        case let .label(item): return Reusable.labelCell.class.size(width: width, item: item)
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
