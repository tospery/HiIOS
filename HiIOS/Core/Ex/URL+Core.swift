//
//  URL+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2023/1/25.
//

import Foundation

public extension URL {
    
    var baseString: String {
        let components = self.absoluteString.components(separatedBy: "/")
        return "\(components.first ?? "")//\(components[safe: 2] ?? "")"
    }
    
    var pathString: String {
        self.absoluteString.removingPrefix(self.baseString).components(separatedBy: "?").first ?? ""
    }
    
}
