//
//  ComponentCell.swift
//  FFUFComponents
//
//  Created by Julio Miguel Alorro on 2/9/19.
//  Copyright © 2019 Feil, Feil, & Feil  GmbH. All rights reserved.
//

import class Dispatch.DispatchQueue
import class UIKit.UICollectionViewCell
import class UIKit.UIColor
import protocol LayoutKit.Layout
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGRect
import struct CoreGraphics.CGSize
import struct Dispatch.DispatchQoS
import struct Foundation.IndexPath
import struct LayoutKit.LayoutMeasurement
import struct LayoutKit.LayoutArrangement

/**
 The ComponentCell serves as the root UIView for the UI elements generated by its Layout
*/
open class ComponentCell: UICollectionViewCell {

    /**
     The String identifier used by the ComponentCell to register to a UICollectionView instance
     */
    open class var identifier: String {
        return String(describing: Mirror(reflecting: self).subjectType)
    }

    // MARK: Layout
    /**
     The current ComponentLayout instance that created and arranged the subviews in the contentView of this ComponentCell.
    */
    private var layout: ComponentLayout?

    override open func prepareForReuse() {
        super.prepareForReuse()
        self.layout = nil
    }

    override public final func layoutSubviews() {

        // Get the rect of the contentView in the main thread.
        let bounds: CGRect = self.contentView.bounds

        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            guard let layout = self.layout else { return }

            // Do the size calculation in a background thread
            let measurement: LayoutMeasurement = layout.measurement(
                within: bounds.size
            )

            let arrangement: LayoutArrangement = measurement
                .arrangement(within: bounds)

            // Size and place the subviews on the main thread
            DispatchQueue.main.async {
                arrangement.makeViews(in: self.contentView)
            }
        }
    }

    override public final func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let size = self.layout?.measurement(within: size).size else { return CGSize.zero }
        return size
    }

    override public final var intrinsicContentSize: CGSize {
        return self.sizeThatFits(
            CGSize(
                width: Constants.screenWidth,
                height: CGFloat.greatestFiniteMagnitude
            )
        )
    }

    /**
     Binds the layout from the AnyComponent instance, sets the contentView.frame.size to the cell's intrinsicContentSize
     and calls setNeedsLayout.
    */
    open func configure(with component: AnyComponent) {
        self.layout = component.layout
        self.contentView.frame.size = self.intrinsicContentSize
        self.setNeedsLayout()
    }

}
