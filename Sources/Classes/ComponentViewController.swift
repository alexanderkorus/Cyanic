//
//  ComponentViewController.swift
//  Cyanic
//
//  Created by Julio Miguel Alorro on 2/7/19.
//  Copyright © 2019 Feil, Feil, & Feil  GmbH. All rights reserved.
//

import class Foundation.NSCoder
import class RxCocoa.BehaviorRelay
import class RxCocoa.PublishRelay
import class RxDataSources.RxCollectionViewSectionedAnimatedDataSource
import class RxSwift.DisposeBag
import class RxSwift.MainScheduler
import class RxSwift.Observable
import class RxSwift.SerialDispatchQueueScheduler
import class UIKit.NSLayoutConstraint
import class UIKit.UICollectionView
import class UIKit.UICollectionViewCell
import class UIKit.UICollectionViewFlowLayout
import class UIKit.UICollectionViewLayout
import class UIKit.UIView
import class UIKit.UIViewController
import enum Foundation.DispatchTimeInterval
import enum RxDataSources.UITableViewRowAnimation
import protocol UIKit.UICollectionViewDelegateFlowLayout
import protocol UIKit.UIViewControllerTransitionCoordinator
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGRect
import struct CoreGraphics.CGSize
import struct Foundation.DispatchQoS
import struct Foundation.IndexPath
import struct Foundation.UUID
import struct RxCocoa.KeyValueObservingOptions
import struct RxDataSources.AnimatableSectionModel
import struct RxDataSources.AnimationConfiguration
import struct RxSwift.RxTimeInterval
import struct UIKit.UIEdgeInsets

/**
 ComponentViewController is a UIViewController with a UICollectionView managed by RxDataSources. It has most of the
 boilerplate needed to have a reactive UICollectionView. It responds to new elements emitted by its ViewModel's state.
 ComponentViewController is the delegate of the UICollectionView and serves as the UICollectionViewDataSource as well.
*/
open class ComponentViewController: CyanicViewController, UICollectionViewDelegateFlowLayout {

    // MARK: UIViewController Lifecycle Methods
    override open func loadView() {
        self.view = UIView()
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.collectionView)

        NSLayoutConstraint.activate([
            self.topAnchorConstraint,
            self.bottomAnchorConstraint,
            self.leadingAnchorConstraint,
            self.trailingAnchorConstraint
        ])
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(ComponentCell.self, forCellWithReuseIdentifier: ComponentCell.identifier)

        // Set up as the UICollectionView's UICollectionViewDelegateFlowLayout,
        // UICollectionViewDelegate, and UIScrollViewDelegate
        self.collectionView.delegate = self

        // When _components emits a new element, bind the new element to the UICollectionView.
        self._components.asDriver()
            .map({ (components: [AnyComponent]) -> [AnimatableSectionModel<String, AnyComponent>] in
                return [AnimatableSectionModel(model: "Test", items: components)]
            })
            .drive(self.collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: Constraints
    /**
     The top anchor NSLayoutConstraint of the UICollectionView in the root UIView.
    */
    public lazy var topAnchorConstraint: NSLayoutConstraint = {
        return self.collectionView.topAnchor
            .constraint(equalTo: self.view.topAnchor, constant: 0.0)
    }()

    /**
     The bottom anchor NSLayoutConstraint of the UICollectionView in the root UIView.
    */
    public lazy var bottomAnchorConstraint: NSLayoutConstraint = {
        return self.collectionView.bottomAnchor
            .constraint(equalTo: self.view.bottomAnchor, constant: 0.0)
    }()

    /**
     The leading anchor NSLayoutConstraint of the UICollectionView in the root UIView.
    */
    public lazy var leadingAnchorConstraint: NSLayoutConstraint = {
        return self.collectionView.leadingAnchor
            .constraint(equalTo: self.view.leadingAnchor, constant: 0.0)
    }()

    /**
     The trailing anchor NSLayoutConstraint of the UICollectionView in the root UIView.
    */
    public lazy var trailingAnchorConstraint: NSLayoutConstraint = {
        return self.collectionView.trailingAnchor
            .constraint(equalTo: self.view.trailingAnchor, constant: 0.0)
    }()

    // MARK: Stored Properties
    // swiftlint:disable:next line_length
    public let dataSource: RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, AnyComponent>> = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, AnyComponent>>(
        configureCell: { (_, cv: UICollectionView, indexPath: IndexPath, component: AnyComponent) -> UICollectionViewCell in
            guard let cell = cv.dequeueReusableCell(
                withReuseIdentifier: ComponentCell.identifier,
                for: indexPath
            ) as? ComponentCell
                else { fatalError("Cell not registered to UICollectionView")}

            cell.configure(with: component)
            return cell
        }
    )

    /**
     The AnyComponent BehaviorRelay. Every time a new element is emitted by this Relay, the UICollectionView is refreshed.
    */
    internal let _components: BehaviorRelay<[AnyComponent]> = BehaviorRelay<[AnyComponent]>(value: [])

    /**
     When the collectionView is loaded, its width and height are initially all zero. When viewWillAppear is called, the views are sized.
     This Observable emits the nonzero widths UICollectionView when it changes. This may not work in some circumstances when this
     ComponentViewController is inside a custom Container UIViewController. If that happens override **width** and use **.exactly**.
    */
    internal private(set) lazy var _widthObservable: Observable<CGFloat> = self.collectionView.rx
        .observeWeakly(CGRect.self, "bounds", options: [KeyValueObservingOptions.new, KeyValueObservingOptions.initial])
        .filter({ (rect: CGRect?) -> Bool in rect?.width != nil && rect?.width != 0.0 })
        .map({ (rect: CGRect?) -> CGFloat in rect!.width })
        .distinctUntilChanged()

    internal private(set) var _width: CGFloat = 0.0

    /**
     The layout of the UICollectionView.
     */
    public let layout: UICollectionViewLayout = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        return layout
    }()

    // MARK: Computed Properties
    open var width: ComponentViewController.Width { return ComponentViewController.Width.automatic }

    // MARK: Views
    /**
     The UICollectionView instance managed by this ComponentViewController subclass.
    */
    public private(set) lazy var collectionView: UICollectionView = UICollectionView(
        frame: CGRect.zero,
        collectionViewLayout: self.layout
    )

    // MARK: Methods
    /**
     Creates an Observables based on ThrottleType and binds it to the AnyComponents Observables.

     It creates a new Observables based on the ViewModels' States and  BaseComponenVC's ThrottleType and
     binds it to the AnyComponents Observable so any new State change creates a new AnyComponents array
     which in turn updates the UICollectionView.

     - Parameters:
        - viewModels: The ViewModels whose States will be observed.
    */
    internal override func setUpObservables(with viewModels: [AnyViewModel]) {
        guard !viewModels.isEmpty else { return }
        let combinedStatesObservables: Observable<[Any]> = viewModels.combineStateObservables()

        let filteredWidth: Observable<CGFloat>

        switch self.width {
            case .automatic:
                filteredWidth = self._widthObservable

            case .exactly(let width):
                filteredWidth = Observable<CGFloat>.just(width)
        }

        let allObservables: Observable<(CGFloat, [Any])> = Observable.combineLatest(
            filteredWidth, combinedStatesObservables
        )

        let throttledStateObservable: Observable<(CGFloat, [Any])> = self.setUpThrottleType(
            on: allObservables,
            throttleType: self.throttleType,
            scheduler: self.scheduler
        )
        .observeOn(self.scheduler)
        .subscribeOn(self.scheduler)
        .debug("\(type(of: self))", trimOutput: false)
        .share()

        // Call buildComponents method when a new element in combinedObservable is emitted
        // Bind the new AnyComponents array to the _components BehaviorRelay.
        // NOTE:
        // RxCollectionViewSectionedAnimatedDataSource.swift line 56.
        // UICollectionView has problems with fast updates. So, there is no point in
        // in executing operations in quick succession when it is throttled anyway.
        throttledStateObservable
            .map({ [weak self] (width: CGFloat, _: [Any]) -> [AnyComponent] in
                guard let s = self else { return [] }
                s._width = width
                var controller: ComponentsController = ComponentsController(width: width)
                s.buildComponents(&controller)
                return controller.components
            })
            .bind(to: self._components)
            .disposed(by: self.disposeBag)

        throttledStateObservable
            .map({ (width: CGFloat, states: [Any]) -> [Any] in
                let width: Any = width as Any
                return [width] + states
            })
            .bind(to: self.state)
            .disposed(by: self.disposeBag)

        throttledStateObservable
            .observeOn(MainScheduler.asyncInstance)
            .bind(
                onNext: { [weak self] (_: CGFloat, _: [Any]) -> Void in
                    self?.invalidate()
                }
            )
            .disposed(by: self.disposeBag)

    }

    /**
     Builds the AnyComponents array.

     This is where you create for logic to add Components to the ComponentsController data structure. This method is
     called every time the State of your ViewModels change. You can access the State(s) via the FFUFComponent enum's
     static functions.

     - Parameters:
        - componentsController: The ComponentsController that is mutated by this method. It is always
                                starts as an empty ComponentsController.
    */
    open func buildComponents(_ componentsController: inout ComponentsController) {}

    // MARK: UICollectionViewDelegateFlowLayout Methods
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if self._components.value.endIndex <= indexPath.item {
            return CGSize.zero
        }

        let layout: ComponentLayout = self._components.value[indexPath.item].layout

        let size: CGSize = CGSize(width: self._width, height: CGFloat.greatestFiniteMagnitude)

        let cellSize: CGSize = layout.measurement(within: size).size
        return cellSize
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let component: AnyComponent = self._components.value[indexPath.item]
        guard let selectable = component.identity.base as? Selectable else { return }
        selectable.onSelect()
    }

}

// MARK: - Width Enum
public extension ComponentViewController {

    /**
     In cases where ComponentViewController is a childViewController. It is sometimes necessary to have an exact width.
     This enum allows the the programmer to specify if there's an exact width for the ComponentViewController or if it should be taken
     cared of by UIKit.
    */
    enum Width {
        /**
         Width is defined by UIKit automatically. It is calculated by taking the UICollectionView's frame width.
        */
        case automatic

        /**
         Width is defined by a constant value.
        */
        case exactly(CGFloat)
    }

}
