//
//  Simple.swift
//  HiIOS
//
//  Created by liaoya on 2022/9/23.
//

import Foundation
import ObjectMapper_Hi

public struct Simple: Subjective {
    
    public var id = 0
    public var divided: Bool? = true
    public var indicated: Bool? = true
    public var height: CGFloat?
    public var icon: String?
    public var title: String?
    public var detail: String?
    public var color: String?
    public var tintColor: String?
    public var target: String?
    
    public var isSpace: Bool { id == 0 }
    public var isButton: Bool { id == 1 }

    public init() { }

    public init?(map: Map) { }
    
    public init(
        id: Int = 0,
        icon: String? = nil,
        title: String? = nil,
        detail: String? = nil,
        indicated: Bool? = true,
        divided: Bool? = true,
        height: CGFloat? = nil,
        color: String? = nil,
        tintColor: String? = nil,
        target: String? = nil
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.detail = detail
        self.indicated = indicated
        self.divided = divided
        self.height = height
        self.color = color
        self.tintColor = tintColor
        self.target = target
    }

    mutating public  func mapping(map: Map) {
        id              <- map["id"]
        height          <- map["height"]
        color           <- map["color"]
        tintColor       <- map["tintColor"]
        icon            <- map["icon"]
        title           <- map["title"]
        detail          <- map["detail"]
        indicated       <- map["indicated"]
        divided         <- map["divided"]
        target          <- map["target"]
    }

}

