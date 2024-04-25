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
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        var queryItems = urlComponents.queryItems ?? []
        for param in parameters {
            if let index = queryItems.firstIndex(where: { $0.name == param.key }) {
                queryItems[index] = URLQueryItem(name: param.key, value: param.value)
            } else {
                queryItems.append(URLQueryItem(name: param.key, value: param.value))
            }
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
    
    mutating func myAppendQueryParameters(_ parameters: [String: String]) {
        self = myAppendingQueryParameters(parameters)
    }
    
    func deletingAllQueryParameters() -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = nil
        return urlComponents.url!
    }
    
    mutating func deleteAllQueryParameters() {
        self = deletingAllQueryParameters()
    }
    
    func myAppendingQueryParameters(_ parameters: [URLQueryItem]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        var queryItems = urlComponents.queryItems ?? []
        for param in parameters {
            if let index = queryItems.firstIndex(where: { $0.name == param.name }) {
                queryItems[index] = param
            } else {
                queryItems.append(param)
            }
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
    
    mutating func myAppendQueryParameters(_ parameters: [URLQueryItem]) {
        self = myAppendingQueryParameters(parameters)
    }
    
}
