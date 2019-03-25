//
//  ButtonComponentType.swift
//  FFUFComponents
//
//  Created by Julio Miguel Alorro on 2/27/19.
//  Copyright © 2019 Feil, Feil, & Feil  GmbH. All rights reserved.
//

import class UIKit.UIButton
import class UIKit.UIColor
import enum LayoutKit.ButtonLayoutType
import struct Alacrity.AlacrityStyle
import struct CoreGraphics.CGFloat
import struct LayoutKit.Alignment
import struct LayoutKit.Flexibility
import struct UIKit.UIEdgeInsets

// sourcery: AutoEquatableComponent,AutoHashableComponent
// sourcery: Component = ButtonComponent
/// ButtonComponentType is a protocol for Components that represents a UIButton.
public protocol ButtonComponentType: StaticHeightComponent {

    // sourcery: defaultValue = ButtonLayoutType.system
    /// The ButtonLayoutType which maps to UIButton.ButtonType. The default value is .system.
    var type: ButtonLayoutType { get set }

    // sourcery: defaultValue = """"
    /// The title displayed as text on the UIButton. The default value is an empty string: "".
    var title: String { get set }

    // sourcery: defaultValue = UIEdgeInsets.zero
    // sourcery: skipHashing, skipEquality
    /// The insets on the UIButton relative to its root UIView. This is NOT the insets on the content inside the
    /// UIButton. The default value is UIEdgeInsets.zero.
    var insets: UIEdgeInsets { get set }

    // sourcery: defaultValue = UIColor.clear
    /// The background color of the UICollectionView's contentView. The default value is UIColor.clear.
    var backgroundColor: UIColor { get set }

    // sourcery: defaultValue = ButtonLayoutDefaults.defaultAlignment
    // sourcery: skipHashing, skipEquality
    /// The alignment of the underlying ButtonLayout and SizeLayout. The default value is
    /// ButtonLayoutDefaults.defaultAlignment.
    var alignment: Alignment { get set }

    // sourcery: defaultValue = ButtonLayoutDefaults.defaultFlexibility
    // sourcery: skipHashing, skipEquality
    /// The flexibility of the underlying ButotnLayout and SizeLayout. The default value is
    /// ButtonLayoutDefaults.defaultFlexibility.
    var flexibility: Flexibility { get set }

    // sourcery: defaultValue = AlacrityStyle<UIButton> { _ in }
    // sourcery: skipHashing, skipEquality
    /// The styling applied to the UIButton. The default value is an empty style.
    var style: AlacrityStyle<UIButton> { get set }

    // sourcery: defaultValue = { print("Hello World \(#file)") }
    // sourcery: skipHashing, skipEquality
    /// The code executed when the UIButton is tapped.
    var onTap: () -> Void { get set }

}
