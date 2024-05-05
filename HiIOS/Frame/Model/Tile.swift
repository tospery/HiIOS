//
//  Tile.swift
//  HiIOS
//
//  Created by liaoya on 2022/9/23.
//

import Foundation
import ObjectMapper_Hi

public struct Tile: Subjective {
    
    public var id = "space"
    public var divided: Bool? = true
    public var indicated: Bool? = false
    public var checked: Bool? = false
    public var height: CGFloat?
    public var icon: String?
    public var title: String?
    public var detail: String?
    public var color: String?
    public var tintColor: String?
    public var target: String?
    
    public var isSpace: Bool { id == "space" }

    public init() { }

    public init?(map: Map) { }
    
    public init(
        id: String = "space",
        icon: String? = nil,
        title: String? = nil,
        detail: String? = nil,
        divided: Bool? = true,
        indicated: Bool? = false,
        checked: Bool? = false,
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
        self.checked = checked
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
        checked         <- map["checked"]
        target          <- map["target"]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(height)
        hasher.combine(color)
        hasher.combine(tintColor)
        hasher.combine(icon)
        hasher.combine(title)
        hasher.combine(detail)
        hasher.combine(indicated)
        hasher.combine(divided)
        hasher.combine(checked)
        hasher.combine(target)
    }

}

