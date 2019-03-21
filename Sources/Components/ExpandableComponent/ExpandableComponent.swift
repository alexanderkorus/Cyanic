//
//  ExpandableComponent.swift
//  FFUFComponents
//
//  Created by Julio Miguel Alorro on 2/15/19.
//  Copyright © 2019 Feil, Feil, & Feil  GmbH. All rights reserved.
//

import class FFUFWidgets.ChevronView
import class RxSwift.DisposeBag
import class RxCocoa.PublishRelay
import class UIKit.UIColor
import class UIKit.UIView
import struct Alacrity.AlacrityStyle
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGSize
import struct LayoutKit.Alignment
import struct UIKit.UIEdgeInsets

// sourcery: AutoComponentType,AutoGenerateComponent,RequiredVariables
// sourcery: ComponentLayout = ExpandableComponentLayout
/// An ExpandableComponent is a Component that represents an expandable UI element that shows/hides other UI elements
/// grouped with it.
public struct ExpandableComponent: ExpandableComponentType, Selectable {

// sourcery:inline:auto:ExpandableComponent.AutoComponentType
    /**
     Work around Initializer because memberwise initializers are all or nothing
     - Parameters:
         - id: The unique identifier of the ExpandableComponent.
    */
    public init(id: String) {
        self.id = id
    }

    public var id: String

    public var width: CGFloat = 0.0

    // sourcery: skipHashing, skipEquality 
    public var contentLayout: ExpandableContentLayout = EmptyContentLayout()

    public var backgroundColor: UIColor = UIColor.clear

    // sourcery: skipHashing, skipEquality 
    public var insets: UIEdgeInsets = UIEdgeInsets.zero

    public var chevronSize: CGSize = CGSize(width: 12.0, height: 12.0)

    // sourcery: skipHashing, skipEquality 
    public var chevronStyle: AlacrityStyle<ChevronView> = AlacrityStyle<ChevronView> { _ in }

    // sourcery: skipHashing, skipEquality 
    public var style: AlacrityStyle<UIView> = AlacrityStyle<UIView> { _ in }

    public var isExpanded: Bool = false

    // sourcery: skipHashing, skipEquality 
    public var setExpandableState: (String, Bool) -> Void = { (_: String, _: Bool) -> Void in
        fatalError("This default closure must be replaced!")
    }

    public var height: CGFloat = 44.0

    // sourcery: skipHashing, skipEquality 
    public var layout: ComponentLayout { return ExpandableComponentLayout(component: self) }

    // sourcery: skipHashing, skipEquality 
    public let cellType: ComponentCell.Type = ComponentCell.self

    public var identity: ExpandableComponent { return self }
// sourcery:end

    public func onSelect() {
        self.setExpandableState(self.id, !self.isExpanded)
    }
}
