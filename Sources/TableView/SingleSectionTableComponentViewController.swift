//
//  SingleSectionTableComponentViewController.swift
//  Cyanic
//
//  Created by Julio Miguel Alorro on 4/15/19.
//  Copyright © 2019 Feil, Feil, & Feil  GmbH. All rights reserved.
//

import class RxCocoa.BehaviorRelay
import class RxDataSources.RxTableViewSectionedAnimatedDataSource
import class RxSwift.Observable
import class UIKit.UITableView
import class UIKit.UITableViewCell
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGSize
import struct Foundation.IndexPath
import struct RxDataSources.AnimatableSectionModel

/**
 SingleSectionTableComponentViewController is a TableComponentViewController subclass that manages a UITableView
 with one section. It has most of the boilerplate needed to have a reactive UITableView
 with a single section. It responds to new elements emitted by its ViewModel(s) State(s).
*/
open class SingleSectionTableComponentViewController: TableComponentViewController { // swiftlint:disable:this type_name

    // MARK: Overridden UIViewController Lifecycle Methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self.setUpDataSource()

        // When _components emits a new element, bind the new element to the UICollectionView.
        self._components
            .map({ (components: [AnyComponent]) -> [AnimatableSectionModel<String, AnyComponent>] in
                return [AnimatableSectionModel<String, AnyComponent>(model: "Cyanic", items: components)]
            })
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }

    // MARK: Stored Properties
    // swiftlint:disable:next implicitly_unwrapped_optional
    public private(set) var dataSource: RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, AnyComponent>>!

    /**
     The AnyComponent BehaviorRelay. Every time a new element is emitted by this relay, the UICollectionView performs a batch
     update based on the diffing produced by RxDataSources.
    */
    internal let _components: BehaviorRelay<[AnyComponent]> = BehaviorRelay<[AnyComponent]>(value: [])

    // MARK: Methods
    /**
     Instantiates the RxCollectionViewSectionedAnimatedDataSource for the UICollectionView.
     - Returns:
        A RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, AnyComponent>> instance.
    */
    open func setUpDataSource() -> RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, AnyComponent>> {
        return RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, AnyComponent>>(
            configureCell: { (_, tv: UITableView, indexPath: IndexPath, component: AnyComponent) -> UITableViewCell in
                guard let cell = tv.dequeueReusableCell(
                    withIdentifier: TableComponentCell.identifier,
                    for: indexPath
                ) as? TableComponentCell
                    else { fatalError("Cell not registered to UICollectionView")}

                cell.configure(with: component)
                return cell
            }
        )
    }

    open override func component(at indexPath: IndexPath) -> AnyComponent? {
        let component: AnyComponent = self._components.value[indexPath.item]
        return component
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
            .map({ [weak self] (size: CGSize, _: [Any]) -> [AnyComponent] in
                guard let s = self else { return [] }
                s._size = size
                let controller: ComponentsController = ComponentsController(size: size)
                s.buildComponents(controller)
                return controller.components
            })
            .bind(to: self._components)
            .disposed(by: self.disposeBag)

        return throttledStateObservable
    }

    /**
     Builds the ComponentsController.

     This is where you create for logic to add Components to the ComponentsController data structure. This method is
     called every time the State of your ViewModels change. You can access the State(s) via the global withState functions
     or a ViewModel's withState instance method.

     - Parameters:
        - componentsController: The ComponentsController that is mutated by this method. It is always
                                starts as an empty ComponentsController.
    */
    open func buildComponents(_ componentsController: ComponentsController) {}

    // MARK: UICollectionViewDelegateFlowLayout Methods
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self._components.value.endIndex <= indexPath.item {
            return 0.0
        }

        guard let layout = self.component(at: indexPath)?.layout
            else { return 0.0}

        let size: CGSize = CGSize(width: self._size.width, height: CGFloat.greatestFiniteMagnitude)

        let rowSize: CGSize = layout.measurement(within: size).size
        return rowSize.height
    }
}
