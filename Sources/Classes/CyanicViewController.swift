//
//  CyanicViewController.swift
//  Cyanic
//
//  Created by Julio Miguel Alorro on 3/21/19.
//  Copyright © 2019 Feil, Feil, & Feil  GmbH. All rights reserved.
//

import class Foundation.NSCoder
import class RxCocoa.BehaviorRelay
import class RxSwift.DisposeBag
import class RxSwift.MainScheduler
import class RxSwift.Observable
import class RxSwift.SerialDispatchQueueScheduler
import class UIKit.UIViewController
import struct Foundation.DispatchQoS
import struct Foundation.UUID

/**
 CyanicViewController is a UIViewController subclass that can listen to State changes to its ViewModels. Whenever the
 State of at least one of its ViewModels changes, its invalidate method is called.
*/
open class CyanicViewController: UIViewController, StateObservableBuilder {

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpObservables(with: self.viewModels)
    }

    // MARK: Stored Properties
    /**
     The serial scheduler where the ViewModel's state changes are observed on and mapped to the _components
     */
    internal let scheduler: SerialDispatchQueueScheduler = SerialDispatchQueueScheduler(
        qos: DispatchQoS.userInitiated,
        internalSerialQueueName: "\(UUID().uuidString)"
    )

    /**
     The combined state of the ViewModels as a BehviorRelay for debugging purposes.
    */
    internal let state: BehaviorRelay<[Any]> = BehaviorRelay<[Any]>(value: [()])

    /**
     DisposeBag for Rx-related subscriptions.
    */
    internal let disposeBag: DisposeBag = DisposeBag()

    // MARK: Computed Properties
    /**
     Limits the frequency of state updates.
    */
    open var throttleType: ThrottleType { return ThrottleType.none }

    /**
     The current state of the ViewModels from the state BehaviorRelay.
    */
    public var currentState: Any { return self.state.value }

    /**
     The ViewModels whose State is observed by this CyanicViewController.
    */
    open var viewModels: [AnyViewModel] { return [] }

    internal typealias CombinedState = [Any]

    // MARK: Methods
    /**
     Creates an Observables based on ThrottleType and binds it to the invalidate method.

     It creates a new Observables based on the ViewModels' States and  CyanicViewController ThrottleType and
     binds it to the invalidate method so any new State change calls the invalidate method.

     - Parameters:
        - viewModels: The ViewModels whose States will be observed.
     */
    @discardableResult
    internal func setUpObservables(with viewModels: [AnyViewModel]) -> Observable<[Any]> {
        guard !viewModels.isEmpty else { return Observable<[Any]>.empty() }
        let combinedStatesObservables: Observable<[Any]> = viewModels
            .combineStateObservables()

        let throttledStateObservable: Observable<[Any]> = self.setUpThrottleType(
            on: combinedStatesObservables,
            throttleType: self.throttleType,
            scheduler: self.scheduler
        )
        .debug("\(type(of: self)) \(#line)", trimOutput: false)
        .observeOn(self.scheduler)
        .subscribeOn(self.scheduler)
        .share()

        throttledStateObservable
            .observeOn(MainScheduler.instance)
            .bind(
                onNext: { [weak self] (_: [Any]) -> Void in
                    self?.invalidate()
                }
            )
            .disposed(by: self.disposeBag)

        throttledStateObservable
            .bind(to: self.state)
            .disposed(by: self.disposeBag)

        return throttledStateObservable
    }

    /**
     When the State of the ViewModel changes, invalidate is called, therefore, you should place logic here that
     should react to changes in state. This method is run on the main thread asynchronously.

     When overriding, no need to call super because the default implementation does nothing.
    */
    open func invalidate() {}

}
