//
//  Data+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation

public extension Data {
    
    static func dataFromFile(withFilename filename: String, at bundleClass: AnyClass? = nil) -> Data? {
        let components = filename.components(separatedBy: ".")
        guard let name = components.first, let type = components.last else { return nil }
        let bundle = bundleClass != nil ? Bundle(for: bundleClass!) : Bundle.main
        guard let path = bundle.path(forResource: name, ofType: type) else { return nil }
        return try? Data(contentsOf: URL(fileURLWithPath: path))
    }
    
}
