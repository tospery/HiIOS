//
//  NSAttributedString+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation

public extension NSAttributedString {

    func size(thatFits size: CGSize) -> CGSize {
        return self.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size
    }

    func width() -> CGFloat {
        return self.size(thatFits: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
    }

    func height(thatFitsWidth width: CGFloat) -> CGFloat {
        return self.size(thatFits: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
    }

}
