//
//  Tile.swift
//  HiIOS
//
//  Created by liaoya on 2022/9/23.
//

import Foundation
import ObjectMapper
import HiCore
import HiDomain

public struct Tile: ModelType {
    
    public var id = "space"
    public var divided: Bool? = true
    public var indicated: Bool? = false
    public var checked: Bool? = false
    public var height: Double?
    public var icon: String?
    public var title: String?
    public var detail: String?
    public var color: String?
    public var tintColor: String?
    public var target: String?
    public var kind: String?
    
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
        height: Double? = nil,
        color: String? = nil,
        tintColor: String? = nil,
        target: String? = nil,
        kind: String? = nil
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
        self.kind = kind
    }

    mutating public  func mapping(map: Map) {
        id              <- (map["id"], StringTransform.shared)
        height          <- (map["height"], DoubleTransform.shared)
        color           <- (map["color"], StringTransform.shared)
        tintColor       <- (map["tintColor"], StringTransform.shared)
        icon            <- (map["icon"], StringTransform.shared)
        title           <- (map["title"], StringTransform.shared)
        detail          <- (map["detail"], StringTransform.shared)
        indicated       <- (map["indicated"], BoolTransform.shared)
        divided         <- (map["divided"], BoolTransform.shared)
        checked         <- (map["checked"], BoolTransform.shared)
        target          <- (map["target"], StringTransform.shared)
        kind            <- (map["kind"], StringTransform.shared)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id &&
        lhs.height == rhs.height &&
        lhs.color == rhs.color &&
        lhs.tintColor == rhs.tintColor &&
        lhs.icon == rhs.icon &&
        lhs.title == rhs.title &&
        lhs.detail == rhs.detail &&
        lhs.indicated == rhs.indicated &&
        lhs.divided == rhs.divided &&
        lhs.checked == rhs.checked &&
        lhs.target == rhs.target &&
        lhs.kind == rhs.kind
    }

}

