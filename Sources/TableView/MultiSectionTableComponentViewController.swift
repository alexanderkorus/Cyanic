//
//  MultiSectionTableComponentViewController.swift
//  Cyanic
//
//  Created by Julio Miguel Alorro on 4/14/19.
//  Copyright © 2019 Feil, Feil, & Feil  GmbH. All rights reserved.
//

import class RxCocoa.BehaviorRelay
import class RxDataSources.RxTableViewSectionedAnimatedDataSource
import class RxSwift.Observable
import class UIKit.UITableView
import class UIKit.UITableViewCell
import class UIKit.UIView
import enum RxDataSources.UITableViewRowAnimation
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGSize
import struct Foundation.IndexPath
import struct RxDataSources.AnimationConfiguration
import struct RxDataSources.AnimatableSectionModel

/**
 MultiSectionTableComponentViewController is a TableComponentViewController subclass that manages a UITableView with
 multiple sections. It has most of the boilerplate needed to have a reactive UITableView with a multiple sections.
 It responds to new elements emitted by its  ViewModel(s) State(s).
*/
open class MultiSectionTableComponentViewController: TableComponentViewController {

    // MARK: Overridden UIViewController Lifecycle Methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self.setUpDataSource()
        // When _components emits a new element, bind the new element to the UITableView.
        self._sections
            .map({ (sections: MultiSectionController) -> [AnimatableSectionModel<AnyComponent, AnyComponent>] in
                let models: [AnimatableSectionModel<AnyComponent, AnyComponent>] = sections.sectionControllers
                    .map({ (section: SectionController) -> AnimatableSectionModel<AnyComponent, AnyComponent> in
                        return AnimatableSectionModel<AnyComponent, AnyComponent>(
                            model: section.sectionComponent,
                            items: section.componentsController.components
                        )
                    })
                return models
            })
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }

    // MARK: Stored Properties
    /**
     The MultiSectionController BehaviorRelay. Every time a new element is emitted by this relay, the UITableView performs
     a batch update based on the diffing produced by RxDataSources.
    */
    internal let _sections: BehaviorRelay<MultiSectionController> = BehaviorRelay<MultiSectionController>(
        value: MultiSectionController(size: CGSize.zero)
    )

    /**
     The RxTableViewSectionedAnimatedDataSource instance.
    */ // swiftlint:disable:next line_length implicitly_unwrapped_optional
    public private(set) var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<AnyComponent, AnyComponent>>!

    // MARK: Methods
    /**
     Instantiates the RxCollectionViewSectionedAnimatedDataSource for the UICollectionView.
     - Returns:
        A RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<AnyComponent, AnyComponent>> instance.
    */
    open func setUpDataSource() -> RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<AnyComponent, AnyComponent>> {
        return RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<AnyComponent, AnyComponent>>(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: UITableViewRowAnimation.fade,
                reloadAnimation: UITableViewRowAnimation.automatic,
                deleteAnimation: UITableViewRowAnimation.fade
            ),
            configureCell: { (_, tv: UITableView, indexPath: IndexPath, component: AnyComponent) -> UITableViewCell in
                guard let cell = tv.dequeueReusableCell(
                    withIdentifier: TableComponentCell.identifier,
                    for: indexPath
                ) as? TableComponentCell
                    else { fatalError("Cell not registered to UITableView")}

                cell.configure(with: component)
                return cell
            }
        )
    }

    open override func component(at indexPath: IndexPath) -> AnyComponent? {
        guard let sectionController = self.sectionController(at: indexPath.section)
            else { return nil }

        guard indexPath.item < sectionController.componentsController.components.count
            else { return nil }

        let component: AnyComponent = sectionController.componentsController.components[indexPath.item]
        return component
    }
    /**
     Gets the SectionController at the specified index if there is one.
     - Parameters:
        - section: The index of the SectionController.
     - Returns:
        A SectionController or nil if the index is out of range.
     */
    public final func sectionController(at section: Int) -> SectionController? {
        guard section < self._sections.value.sectionControllers.count  else {
            return nil
        }

        let sectionController: SectionController = self._sections.value.sectionControllers[section]
        return sectionController
    }

    internal typealias Element = (CGSize, [Any])

    internal override func setUpObservables(with viewModels: [AnyViewModel]) -> Observable<(CGSize, [Any])> {
        let throttledStateObservable: Observable<(CGSize, [Any])> = super.setUpObservables(with: viewModels)

        // Call buildComponents method when a new element in combinedObservable is emitted
        // Bind the new AnyComponents array to the _components BehaviorRelay.
        // NOTE:
        // RxCollectionViewSectionedAnimatedDataSource.swift line 56.
        // UICollectionView has problems with fast updates. So, there is no point in
        // in executing operations in quick succession when it is throttled anyway.
        throttledStateObservable
            .map({ [weak self] (size: CGSize, _: [Any]) -> MultiSectionController in
                guard let s = self else { return MultiSectionController(size: CGSize.zero) }
                s._size = size
                var controller: MultiSectionController = MultiSectionController(size: size)
                s.buildSections(&controller)
                return controller
            })
            .bind(to: self._sections)
            .disposed(by: self.disposeBag)

        return throttledStateObservable
    }

    /**
     Builds the MultiSectionController.

     This is where you create the logic to add Components to the MultiSectionController data structure. This method is
     called every time the State(s) of your ViewModel(s) change. You can access the State(s) via the global withState methods or
     a ViewModel's withState instance method.
     - Parameters:
        - sections: The MultiSectionController that is mutated by this method. It always
                    starts as an empty MultiSectionController.
     */
    open func buildSections(_ sectionsController: inout MultiSectionController) {}

    // MARK: UITableViewDelegate Methods
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self._sections.value.sectionControllers.count < indexPath.section {
            return 0.0
        }

        guard let layout = self.component(at: indexPath)?.layout
            else { return 0.0 }

        let size: CGSize = CGSize(width: self._size.width, height: CGFloat.greatestFiniteMagnitude)

        let rowSize: CGSize = layout.measurement(within: size).size
        return rowSize.height
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self._sections.value.sectionControllers.count < section {
            return 0.0
        }

        guard let layout = self.sectionController(at: section)?.sectionComponent?.layout
            else { return 0.0 }

        let size: CGSize = CGSize(width: self._size.width, height: CGFloat.greatestFiniteMagnitude)

        let headerSize: CGSize = layout.measurement(within: size).size
        return headerSize.height
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let component = self.sectionController(at: section)?.sectionComponent else { return nil }
        let headerView: TableComponentHeaderView = TableComponentHeaderView()
        headerView.configure(with: component)
        return headerView
    }
}
