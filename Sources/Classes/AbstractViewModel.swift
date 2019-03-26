//
//  ViewModelType.swift
//  FFUFComponents
//
//  Created by Julio Miguel Alorro on 3/4/19.
//  Copyright © 2019 Feil, Feil, & Feil  GmbH. All rights reserved.
//

import class RxCocoa.BehaviorRelay
import class RxSwift.DisposeBag
import class RxSwift.Observable

/**
 AbstractViewModel is a class that provides the essential functionality that must exist in all ViewModel subclasses.
*/
open class AbstractViewModel<StateType: State>: ViewModelType {

    /**
     Initializer for the ViewModel.
     When instantiating the ViewModel, it is important to pass an initial State object which should represent
     the initial State of the current view / screen of the app.
     - Parameters:
        - initialState: The starting State of the ViewModel.
    */
    public init(initialState: StateType, isDebugMode: Bool = false) {
        self.stateStore = StateStore<StateType>(initialState: initialState)
        self.isDebugMode = isDebugMode
    }

    deinit {
        if self.isDebugMode {
            print("\(self) was deallocated")
        }
    }

    /**
     The StateStore that manages the State of the ViewModel
    */
    internal let stateStore: StateStore<StateType>

    /**
     Indicates whether debugging functionality will be used.
    */
    internal let isDebugMode: Bool

    /**
     The DisposeBag used to clean up any Rx related subscriptions related to the ViewModel instance.
    */
    public let disposeBag: DisposeBag = DisposeBag()

}

internal extension AbstractViewModel {

    /**
     Accessor for the State Observable of the AbstractViewModel.
    */
    var state: Observable<StateType> {
        return self.stateStore.state
    }

    /**
     Accessor for the current State of the AbstractViewModel.
    */
    var currentState: StateType {
        return self.stateStore.currentState
    }

}

internal protocol ViewModelType {}
