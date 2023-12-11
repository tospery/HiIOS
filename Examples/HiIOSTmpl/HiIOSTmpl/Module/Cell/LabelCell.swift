//
//  LabelCell.swift
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
import TTTAttributedLabel
import BonMot
import HiIOS

class LabelCell: BaseCollectionCell, ReactorKit.View {
    
    struct Metric {
        static let margin = UIEdgeInsets.init(horizontal: 40, vertical: 30)
    }
    
    let clickSubject = PublishSubject<String>()
    var attributedText: NSAttributedString?
    var links: [String]?

    lazy var label: TTTAttributedLabel = {
        let label = TTTAttributedLabel.init(frame: .zero)
        label.delegate = self
        label.numberOfLines = 0
        label.verticalAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.sizeToFit()
        self.label.width = self.contentView.width - Metric.margin.horizontal
        self.label.height = self.contentView.height
        self.label.left = self.label.leftWhenCenter
        self.label.top = self.label.topWhenCenter
    }

    func bind(reactor: LabelItem) {
        super.bind(item: reactor)
        reactor.state.map { $0.info?.alignment ?? .left }
            .distinctUntilChanged()
            .bind(to: self.rx.alignment)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.info?.attributedText }
            .distinctUntilChanged()
            .bind(to: self.rx.attributedText)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.info?.color }
            .distinctUntilChanged()
            .bind(to: self.contentView.rx.backgroundColor)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.info?.links?.keys.sorted() }
            .distinctUntilChanged()
            .bind(to: self.rx.links)
            .disposed(by: self.disposeBag)
        reactor.state.map { _ in }
            .bind(to: self.rx.setNeedsLayout)
            .disposed(by: self.disposeBag)
    }
    
    func setup() {
        if self.attributedText == nil || self.links == nil {
            return
        }
        self.label.setText(self.attributedText)
        let text = self.label.attributedText.string
        for link in self.links! {
            if let start = text.range(of: link) {
                self.label.addLink(.init(
                    attributes: [
                        NSAttributedString.Key.foregroundColor: UIColor.primary,
                        NSAttributedString.Key.font: UIFont.bold(16)
                    ],
                    activeAttributes: [
                        NSAttributedString.Key.foregroundColor: UIColor.red
                    ],
                    inactiveAttributes: [
                        NSAttributedString.Key.foregroundColor: UIColor.gray
                    ],
                    textCheckingResult: .spellCheckingResult(range: text.nsRange(from: start))
                ))
            }
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override class func size(width: CGFloat, item: BaseCollectionItem) -> CGSize {
        guard let item = item as? LabelItem else { return .zero }
        var height = UILabel.size(
            attributedString: item.currentState.info?.attributedText,
            withConstraints: .init(
                width: width - Metric.margin.horizontal,
                height: .greatestFiniteMagnitude
            ),
            limitedToNumberOfLines: 0
        ).height
        height += Metric.margin.vertical
        return .init(width: width, height: height)
    }

}

extension LabelCell: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith result: NSTextCheckingResult!) {
        guard let text = label.attributedText?.string else { return }
        let start = result.range.location
        let end = start + result.range.length
        let link = String.init(text[start..<end])
        if link.isEmpty {
            return
        }
        guard let element = (self.model as? BaseModel)?.data as? SectionItemElement else { return }
        if case let .label(info) = element {
            guard let target = info.links?.string(for: link), target.isNotEmpty else { return }
            self.clickSubject.onNext(target)
        }
    }

}

extension Reactive where Base: LabelCell {
    
    var click: ControlEvent<String> {
        .init(events: self.base.clickSubject)
    }
    
    var alignment: Binder<NSTextAlignment> {
        return Binder(self.base) { cell, alignment in
            cell.label.textAlignment = alignment
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
    }
    
    var attributedText: Binder<NSAttributedString?> {
        return Binder(self.base) { cell, attributedText in
            cell.attributedText = attributedText
            cell.setup()
        }
    }
    
    var links: Binder<[String]?> {
        return Binder(self.base) { cell, links in
            cell.links = links
            cell.setup()
        }
    }
    
}
