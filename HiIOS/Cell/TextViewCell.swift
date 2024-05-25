//
//  TextViewCell.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/5.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi
import HiTheme

open class TextViewCell: BaseCollectionCell, ReactorKit.View {
    
    struct Metric {
        static let maxChars = 160
        static let labelWidth = 55.f
    }
    
    lazy var label: UILabel = {
        let label = UILabel.init()
        label.font = .normal(14)
        label.textAlignment = .right
        label.theme.textColor = themeService.attribute { $0.footerColor }
        label.sizeToFit()
        label.height = label.font.lineHeight
        label.width = Metric.labelWidth
        return label
    }()
    
    public lazy var textView: UITextView = {
        let textView = UITextView.init()
        textView.font = .normal(16)
        textView.theme.textColor = themeService.attribute { $0.foregroundColor }
        textView.rx.text
            .subscribeNext(weak: self, type(of: self).handleText)
            .disposed(by: self.rx.disposeBag)
        textView.sizeToFit()
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.textView)
        self.contentView.addSubview(self.label)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.textView.sizeToFit()
        self.textView.width = self.contentView.width - 20 * 2
        self.textView.height = self.contentView.height
        self.textView.left = self.textView.leftWhenCenter
        self.textView.top = self.textView.topWhenCenter
        self.label.right = self.textView.right
        self.label.bottom = self.textView.bottom - 10
    }

    public func bind(reactor: TextViewItem) {
        super.bind(item: reactor)
        reactor.state.map { $0.text }
            .distinctUntilChanged()
            .bind(to: self.rx.text)
            .disposed(by: self.disposeBag)
        reactor.state.map { _ in }
            .bind(to: self.rx.setNeedsLayout)
            .disposed(by: self.disposeBag)
    }
    
    func handleText(text: String?) {
        if let text = text, text.count > Metric.maxChars {
            self.textView.text = String.init(text.prefix(Metric.maxChars))
        }
        self.label.text = "\(text?.count ?? 0)/\(Metric.maxChars)"
    }
    
    open override class func size(width: CGFloat, item: BaseCollectionItem) -> CGSize {
        .init(width: width, height: 140)
    }

}

public extension Reactive where Base: TextViewCell {
    
    var text: ControlProperty<String?> {
        self.base.textView.rx.text
    }
    
}
