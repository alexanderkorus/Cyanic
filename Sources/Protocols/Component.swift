//
//  Component.swift
//  FFUFComponents
//
//  Created by Julio Miguel Alorro on 2/7/19.
//  Copyright © 2019 Feil, Feil, & Feil  GmbH. All rights reserved.
//

import class RxSwift.DisposeBag
import protocol Differentiator.IdentifiableType

/**
 Component is the data model representation of the UICollectionViewCell to be rendered on the BaseComponentVC.
 A Component should be an immutable class because its a data model.
 Information it contains:
 - The ComponentLayout, which defines the following characteristics of the subviews in the the ComponentCell
    - the sizing
    - the location
    - UI properties such as backgroundColor
 - The subclass of ComponentCell it will render
*/
public protocol Component: IdentifiableType where Identity == Self {

    /**
     The unique ID of the component.
    */
    var id: String { get }

    /**
     The LayoutKit related class that will calculate size, location and configuration of the subviews in the ComponentCell
    */
    // sourcery: defaultValue = fatalError()
    // sourcery: isComputed = true
    var layout: ComponentLayout { get }

    /**
     The ComponentCell subclass used as the root view for the subviews.
    */
    // sourcery: defaultValue = ComponentCell.self
    var cellType: ComponentCell.Type { get }

    /**
     The isEqual method is used to compare subclasses with each other. It's a workaround due to == being a static method.
     - parameter other: The other instance this instance is being compared to.
     - Returns: Bool
    */
    func isEqual(to other: Self) -> Bool

}

public extension Component {

    /**
     Since Component has a generic constraint. AnyComponent is used as a type erased wrapper around it so Components can be grouped in Collections.
     - Returns: This instance as an AnyComponent.
    */
    func asAnyComponent() -> AnyComponent {
        return AnyComponent(self)
    }

    var identity: Self {
        return self
    }

}




