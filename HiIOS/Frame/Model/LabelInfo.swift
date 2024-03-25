//
//  LabelInfo.swift
//  HiIOS
//
//  Created by 杨建祥 on 2023/1/12.
//

import UIKit

public struct LabelInfo: CustomStringConvertible {

    public let attributedText: NSAttributedString?
    public let alignment: NSTextAlignment?
    public let links: [String: String]?
    public let color: UIColor?
    
    public init(
        attributedText: NSAttributedString? = nil,
        alignment: NSTextAlignment? = nil,
        links: [String: String]? = nil,
        color: UIColor? = nil
    ) {
        self.attributedText = attributedText
        self.alignment = alignment
        self.links = links
        self.color = color
    }
    
    public var description: String {
        self.attributedText?.string ?? ""
    }

}
