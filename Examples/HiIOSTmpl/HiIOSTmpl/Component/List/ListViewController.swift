//
//  ListViewController.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/10.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RswiftResources
import HiIOS
import ReusableKit
import ObjectMapper_Hi
import RxDataSources
import RxGesture

// swiftlint:disable type_body_length
class ListViewController: HiIOS.CollectionViewController, ReactorKit.View {
    
    struct Reusable {
        static let appInfoCell = ReusableCell<AppInfoCell>()
        static let eventCell = ReusableCell<EventCell>()
        static let labelCell = ReusableCell<LabelCell>()
        static let buttonCell = ReusableCell<ButtonCell>()
        static let textFieldCell = ReusableCell<TextFieldCell>()
        static let textViewCell = ReusableCell<TextViewCell>()
        static let imageViewCell = ReusableCell<ImageViewCell>()
        static let baseHeader = ReusableView<BaseCollectionHeader>()
        static let baseFooter = ReusableView<BaseCollectionFooter>()
    }
    
    lazy var dataSource: RxCollectionViewSectionedReloadDataSource<Section> = {
        return .init(
            configureCell: { [weak self] dataSource, collectionView, indexPath, sectionItem in
                guard let `self` = self else { return collectionView.emptyCell(for: indexPath)}
                return self.cell(dataSource, collectionView, indexPath, sectionItem)
            },
            configureSupplementaryView: { [weak self] _, collectionView, kind, indexPath in
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
        )
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
        self.collectionView.register(Reusable.appInfoCell)
        self.collectionView.register(Reusable.eventCell)
        self.collectionView.register(Reusable.labelCell)
        self.collectionView.register(Reusable.buttonCell)
        self.collectionView.register(Reusable.textFieldCell)
        self.collectionView.register(Reusable.textViewCell)
        self.collectionView.register(Reusable.imageViewCell)
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
    
    // swiftlint:disable function_body_length
    // MARK: - cell/header/footer
    func cell(
        _ dataSource: CollectionViewSectionedDataSource<Section>,
        _ collectionView: UICollectionView,
        _ indexPath: IndexPath,
        _ sectionItem: Section.Item
    ) -> UICollectionViewCell {
        switch sectionItem {
        case let .appInfo(item):
            let cell = collectionView.dequeue(Reusable.appInfoCell, for: indexPath)
            item.parent = self.reactor
            cell.reactor = item
            cell.rx.tapLogo
                .subscribeNext(weak: self, type(of: self).tapLogo)
                .disposed(by: cell.disposeBag)
            return cell
        case let .event(item):
            let cell = collectionView.dequeue(Reusable.eventCell, for: indexPath)
            item.parent = self.reactor
            cell.reactor = item
//            cell.rx.click
//                .subscribeNext(weak: self, type(of: self).handleTarget)
//                .disposed(by: cell.disposeBag)
            return cell
        case let .label(item):
            let cell = collectionView.dequeue(Reusable.labelCell, for: indexPath)
            item.parent = self.reactor
            cell.reactor = item
            cell.rx.click
                .subscribeNext(weak: self, type(of: self).handleTarget)
                .disposed(by: cell.disposeBag)
            return cell
        case let .button(item):
            let cell = collectionView.dequeue(Reusable.buttonCell, for: indexPath)
            item.parent = self.reactor
            cell.reactor = item
            cell.rx.tapButton
                .map { Reactor.Action.execute(value: nil, active: true, needLogin: false) }
                .bind(to: self.reactor!.action)
                .disposed(by: cell.disposeBag)
            return cell
        case let .textField(item):
            let cell = collectionView.dequeue(Reusable.textFieldCell, for: indexPath)
            item.parent = self.reactor
            cell.reactor = item
            cell.rx.text
                .asObservable()
                .distinctUntilChanged()
                .map(Reactor.Action.data)
                .observe(on: MainScheduler.asyncInstance)
                .bind(to: self.reactor!.action)
                .disposed(by: cell.disposeBag)
            return cell
        case let .textView(item):
            let cell = collectionView.dequeue(Reusable.textViewCell, for: indexPath)
            item.parent = self.reactor
            cell.reactor = item
            cell.rx.text
                .asObservable()
                .distinctUntilChanged()
                .map(Reactor.Action.data)
                .observe(on: MainScheduler.asyncInstance)
                .bind(to: self.reactor!.action)
                .disposed(by: cell.disposeBag)
            return cell
        case let .imageView(item):
            let cell = collectionView.dequeue(Reusable.imageViewCell, for: indexPath)
            item.parent = self.reactor
            cell.reactor = item
            return cell
        }
    }
    // swiftlint:enable function_body_length
    
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
        // let username = self.reactor?.username ?? ""
    }
    
    func tapUser(username: String) {
        self.navigator.forward(Router.shared.urlString(host: .user, path: username))
    }
    
    func tapQuery(query: String) {
    }
    
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
        case let .appInfo(item): return Reusable.appInfoCell.class.size(width: width, item: item)
        case let .event(item): return Reusable.eventCell.class.size(width: width, item: item)
        case let .label(item): return Reusable.labelCell.class.size(width: width, item: item)
        case let .button(item): return Reusable.buttonCell.class.size(width: width, item: item)
        case let .textField(item): return Reusable.textFieldCell.class.size(width: width, item: item)
        case let .textView(item): return Reusable.textViewCell.class.size(width: width, item: item)
        case let .imageView(item): return Reusable.imageViewCell.class.size(width: width, item: item)
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
// swiftlint:enable type_body_length
