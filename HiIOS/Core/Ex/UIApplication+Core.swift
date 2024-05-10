//
//  UIApplication+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import UIKit
import SwifterSwift

public extension UIApplication {
    
    private static var _inAppStore: Bool?
    var inAppStore: Bool {
        if UIApplication._inAppStore == nil {
            UIApplication._inAppStore = self.inferredEnvironment == .appStore
        }
        return UIApplication._inAppStore!
    }
    
    var team: String {
        let query = [
            kSecClass as NSString: kSecClassGenericPassword as NSString,
            kSecAttrAccount as NSString: "bundleSeedID" as NSString,
            kSecAttrService as NSString: "" as NSString,
            kSecReturnAttributes as NSString: kCFBooleanTrue as NSNumber
        ] as NSDictionary
        
        var result: CFTypeRef?
        var status = Int(SecItemCopyMatching(query, &result))
        if status == Int(errSecItemNotFound) {
            status = Int(SecItemAdd(query, &result))
        }
        if status == Int(errSecSuccess),
            let attributes = result as? NSDictionary,
            let accessGroup = attributes[kSecAttrAccessGroup as NSString] as? NSString,
            let bundleSeedID = (accessGroup.components(separatedBy: ".") as NSArray).objectEnumerator().nextObject() as? String {
            return bundleSeedID
        }
        
        return ""
    }
    
    var urlScheme: String {
        self.urlScheme(name: "app") ?? ""
    }
    
    var name: String {
        self.displayName ?? self.bundleName
    }
    
    var displayName: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
    
    
    var bundleName: String {
        Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String
    }
    
    var bundleIdentifier: String {
        Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as! String
    }
    
    var appIcon: UIImage? {
        guard let info = (Bundle.main.infoDictionary as NSDictionary?) else { return nil }
        guard let name = (info.value(forKeyPath: "CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles") as? Array<String>)?.last else { return nil }
        return UIImage(named: name)
    }
    
    var window: UIWindow {
        var window: UIWindow?
        if #available(iOS 13, *) {
            window = UIApplication.shared.windows.filter { $0.isKeyWindow }.last
        } else {
            window = UIApplication.shared.keyWindow
        }
        return window!
    }
    
    @objc var pageStart: Int { 0 }
    
    @objc var pageSize: Int { 20 }
    
    @objc var baseApiUrl: String {
        var domain = self.linkDomains.first ?? ""
        if domain.isEmpty {
            domain = "\(self.urlScheme).com"
        }
        return "https://\(domain)"
    }
    
    @objc var baseWebUrl: String {
        var domain = self.linkDomains.first ?? ""
        if domain.isEmpty {
            domain = "\(self.urlScheme).com"
        }
        return "https://\(domain)"
    }
    
    func urlScheme(name: String) -> String? {
        var scheme: String? = nil
        if let types = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? Array<Dictionary<String, Any>> {
            for info in types {
                if let urlName = info["CFBundleURLName"] as? String,
                   urlName == name {
                    if let urlSchemes = info["CFBundleURLSchemes"] as? [String] {
                        scheme = urlSchemes.first
                    }
                }
            }
        }
        return scheme
    }

    var linkDomains: [String] {
        Bundle.main.infoDictionary?["linkDomains"] as? [String] ?? []
    }
    
}
