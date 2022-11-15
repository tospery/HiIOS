//
//  Portal.swift
//  HiIOS
//
//  Created by liaoya on 2022/9/23.
//

import Foundation
import ObjectMapper_Hi

public struct Portal: ModelType, Identifiable {

    public var id = 0
    public var icon: String?
    public var title: String?
    public var detail: String?
    public var indicated = true
    public var divided = true
    public var height: CGFloat?
    public var color: String?

    public init() {
    }
    
    public init(
        id: Int,
        icon: String? = nil,
        title: String? = nil,
        detail: String? = nil,
        indicated: Bool = true,
        divided: Bool = true,
        height: CGFloat? = 50,
        color: String? = nil
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.detail = detail
        self.indicated = indicated
        self.divided = divided
        self.height = height
        self.color = color
    }

    public init?(map: Map) {
    }

    mutating public func mapping(map: Map) {
        id              <- map["id"]
        height          <- map["height"]
        color           <- map["color"]
        icon            <- map["icon"]
        title           <- map["title"]
        detail          <- map["detail"]
        indicated       <- map["indicated"]
        divided         <- map["divided"]
    }
    
}
