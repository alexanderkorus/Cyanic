//
//  Cyanic
//  Created by Julio Miguel Alorro on 09.02.19.
//  Licensed under the MIT license. See LICENSE file
//

import Foundation
import LayoutKit
import UIKit

/**
 CollectionComponentCell serves as the root UIView for the UI elements generated by its Layout.
*/
open class CollectionComponentCell: UICollectionViewCell {

    /**
     The String identifier used by the CollectionComponentCell to register to a UICollectionView instance
    */
    open class var identifier: String {
        return String(describing: Mirror(reflecting: self).subjectType)
    }

    // MARK: Layout
    /**
     The current ComponentLayout instance that created and arranged the subviews in the contentView of this CollectionComponentCell.
    */
    private var layout: ComponentLayout?

    override open func prepareForReuse() {
        super.prepareForReuse()
        self.layout = nil
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
     Reads the layout from the AnyComponent instance to create the subviews in this CollectionComponentCell instance. This also
     sets the contentView.frame.size to the cell's intrinsicContentSize and calls setNeedsLayout.
     - Parameters:
        - component: The AnyComponent instance that represents this CollectionComponentCell
    */
    open func configure(with component: AnyComponent) {
        self.layout = component.layout
        self.contentView.frame.size = self.intrinsicContentSize

        self.layout?.arrangement(
            origin: self.contentView.bounds.origin,
            width: self.contentView.bounds.size.width,
            height: self.contentView.bounds.size.height
        )
            .makeViews(in: self.contentView)
    }

}
