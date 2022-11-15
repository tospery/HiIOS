//
//  NSRegularExpression+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation

public extension NSRegularExpression {
    
    func firstMatchString(
        in string: String,
        options: MatchingOptions = [],
        range: Range<String.Index>,
        at index: Int
    ) -> String? {
        guard let result = self.firstMatch(in: string, options: options, range: .init(range, in: string)) else { return nil }
        guard index < result.numberOfRanges else { return nil }
        guard let range = Range<String.Index>.init(result.range(at: index), in: string) else { return nil }
        return String.init(string[range])
    }
    
}
