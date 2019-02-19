//
//  StaticSpacingComponent.swift
//  FFUFComponents
//
//  Created by Julio Miguel Alorro on 2/14/19.
//  Copyright © 2019 Feil, Feil, & Feil  GmbH. All rights reserved.
//

import Foundation
import UIKit

public final class StaticSpacingComponent: Component, AutoEquatable, AutoHashable {

    public init(id: String, height: CGFloat = 0.0, backgroundColor: UIColor = UIColor.clear) {
        self.id = id
        self.height = height
        self.backgroundColor = backgroundColor
    }

    public let id: String
    public let backgroundColor: UIColor
    public let height: CGFloat

    public var layout: ComponentLayout {
        return StaticSpacingComponentLayout(height: self.height, backgroundColor: self.backgroundColor)
    }

    //sourcery:skipHashing,skipEquality
    public let cellType: ComponentCell.Type = ComponentCell.self

    public var identity: StaticSpacingComponent {
        return self
    }

    public func isEqual(to other: StaticSpacingComponent) -> Bool {
        return self == other
    }
}
