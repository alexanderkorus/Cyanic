//
//  StaticSpacingComponent.swift
//  FFUFComponents
//
//  Created by Julio Miguel Alorro on 2/14/19.
//  Copyright © 2019 Feil, Feil, & Feil  GmbH. All rights reserved.
//

import class UIKit.UIColor
import struct CoreGraphics.CGSize

// sourcery: AutoComponentType,AutoGenerateComponent
// sourcery: ComponentLayout = StaticSpacingComponentLayout
/// StaticSpacingComponent is a Component that represents static spacing between content / other Components.
public struct StaticSpacingComponent: StaticSpacingComponentType {

// sourcery:inline:auto:StaticSpacingComponent.AutoComponentType
    /**
     Work around Initializer because memberwise initializers are all or nothing
     - Parameters:
         - id: The unique identifier of the StaticSpacingComponent.
    */
    public init(id: String) {
        self.id = id
    }

    public var id: String

    public var size: CGSize = CGSize(width: Constants.screenWidth, height: 44.0)

    public var backgroundColor: UIColor = UIColor.clear

    // sourcery: skipHashing, skipEquality 
    public var layout: ComponentLayout { return StaticSpacingComponentLayout(component: self) }

    // sourcery: skipHashing, skipEquality 
    public let cellType: ComponentCell.Type = ComponentCell.self

    public var identity: StaticSpacingComponent { return self }
// sourcery:end
}
