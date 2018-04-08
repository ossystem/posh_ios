//
// Created by Timofey on 1/15/18.
// Copyright (c) 2018 Jufy. All rights reserved.
//

import Foundation
import RxSwift

class RefreshableAndRecoverable<T>: ObservableType {

    typealias E = T
    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return Recoverable(
            origin: refreshableOrigin,
            recoveringOn: recoverMeans,
            reportingErrorsTo: errorsSubject
        ).subscribe(observer)
    }

    private let refreshableOrigin: RefreshableByRefreshControl<T>
    private let recoverMeans: Observable<Void>
    private let errorsSubject: PublishSubject<Swift.Error>

    init<Origin>(
        origin: Origin,
        refreshControl: UIRefreshControl,
        reportingErrorsTo errorsSubject: PublishSubject<Swift.Error> = PublishSubject()
    ) where Origin: ObservableType, Origin.E == T {
        self.refreshableOrigin = RefreshableByRefreshControl(origin: origin, updatedOn: refreshControl)        
        self.recoverMeans = refreshControl.rx.controlEvent(.valueChanged).asObservable()
        self.errorsSubject = errorsSubject
    }

//    func refresh() {
//
//    }

}
