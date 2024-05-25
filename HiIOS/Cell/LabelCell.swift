//
//  LabelCell.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/5.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi
import TTTAttributedLabel
import HiTheme
import BonMot

open class LabelCell: BaseCollectionCell, ReactorKit.View {
    
    struct Metric {
        static let margin = UIEdgeInsets.init(horizontal: 40, vertical: 30)
    }
    
    public let clickSubject = PublishSubject<String>()
    public var attributedText: NSAttributedString?
    public var links: [String]?

    lazy var label: AttributedLabel = {
        let label = AttributedLabel.init(frame: .zero)
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

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.label.sizeToFit()
        self.label.width = self.contentView.width - Metric.margin.horizontal
        self.label.height = self.contentView.height
        self.label.left = self.label.leftWhenCenter
        self.label.top = self.label.topWhenCenter
        
    }

    public func bind(reactor: LabelItem) {
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
        reactor.state.map { $0.info?.color }
            .distinctUntilChanged()
            .bind(to: self.label.rx.backgroundColor)
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
    
    open func click(_ link: String) {
    }
    
    open override class func size(width: CGFloat, item: BaseCollectionItem) -> CGSize {
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
    
    open func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith result: NSTextCheckingResult!) {
        guard let text = label.attributedText?.string else { return }
        let start = result.range.location
        let end = start + result.range.length
        let link = String.init(text[start..<end])
        if link.isEmpty {
            return
        }
        self.click(link)
    }

}

public extension Reactive where Base: LabelCell {
    
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
