//
//  ButtonComponent2.swift
//  FFUFComponents
//
//  Created by Julio Miguel Alorro on 2/27/19.
//  Copyright © 2019 Feil, Feil, & Feil  GmbH. All rights reserved.
//

import class LayoutKit.ButtonLayoutDefaults
import class UIKit.UIButton
import class UIKit.UIColor
import enum LayoutKit.ButtonLayoutType
import struct Alacrity.AlacrityStyle
import struct CoreGraphics.CGFloat
import struct LayoutKit.Alignment
import struct LayoutKit.Flexibility
import struct UIKit.UIEdgeInsets

// sourcery: AutoEquatable,AutoHashable
public struct ButtonComponent: ButtonComponentType, Changeable {

    public var type: ButtonLayoutType = ButtonLayoutType.system

    public var title: String = ""

    public var height: CGFloat = 44.0

    // sourcery: skipHashing, skipEquality 
    public var insets: UIEdgeInsets = UIEdgeInsets.zero

    public var backgroundColor: UIColor = UIColor.clear

    // sourcery: skipHashing, skipEquality 
    public var alignment: Alignment = ButtonLayoutDefaults.defaultAlignment

    // sourcery: skipHashing, skipEquality 
    public var flexibility: Flexibility = ButtonLayoutDefaults.defaultFlexibility

    // sourcery: skipHashing, skipEquality 
    public var style: AlacrityStyle<UIButton> = AlacrityStyle<UIButton> { _ in }

    // sourcery: skipHashing, skipEquality 
    public var onTap: () -> Void = { print("Hello World \(#file)") }

    public var identity: ButtonComponent { return self }

    public var id: String

    // sourcery: skipHashing, skipEquality 
    public var layout: ComponentLayout {
        return ButtonComponentLayout(
            type: self.type,
            title: self.title,
            backgroundColor: self.backgroundColor,
            height: self.height,
            contentEdgeInsets: self.insets,
            alignment: self.alignment,
            flexibility: self.flexibility,
            viewReuseId: self.id,
            style: self.style,
            onTap: self.onTap
        )
    }

    // sourcery: skipHashing, skipEquality 
    public let cellType: ComponentCell.Type = ComponentCell.self
}

public extension ButtonComponent {

    init(id: String) {
        self.id = id
    }
}
