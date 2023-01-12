//
//  LabelInfo.swift
//  HiIOS
//
//  Created by 杨建祥 on 2023/1/12.
//

import UIKit

public struct LabelInfo: CustomStringConvertible {

    public let attributedText: NSAttributedString?
    public let links: [String]?
    public let alignment: NSTextAlignment?
    public let color: UIColor?
    
    public init(
        attributedText: NSAttributedString? = nil,
        links: [String]? = nil,
        alignment: NSTextAlignment? = nil,
        color: UIColor? = nil
    ) {
        self.attributedText = attributedText
        self.links = links
        self.alignment = alignment
        self.color = color
    }
    
    public var description: String {
        self.attributedText?.string ?? ""
    }

}
