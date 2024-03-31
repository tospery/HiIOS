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
    
    func myAppendingQueryParameters(_ parameters: [String: String]) -> URL {
        guard var components = URLComponents.init(url: self, resolvingAgainstBaseURL: true) else { return self }
        var items = components.queryItems ?? []
        for param in parameters {
            if let index = items.firstIndex(where: { $0.name == param.key }) {
                items[index] = URLQueryItem(name: param.key, value: param.value)
            } else {
                items.append(URLQueryItem(name: param.key, value: param.value))
            }
        }
        components.queryItems = items
        return components.url ?? self
    }
    
    func deletingAllQueryParameters() -> URL {
        guard var components = URLComponents.init(url: self, resolvingAgainstBaseURL: true) else { return self }
        components.queryItems = nil
        return components.url ?? self
    }
    
}
