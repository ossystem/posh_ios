//
// Created by Timofey on 7/29/17.
// Copyright (c) 2017 Jufy. All rights reserved.
//

import Foundation
import RxSwift

//TODO: Implement a Recoverable that propagates errors and use it instead of this one
class Recoverable<T>: ObservableType {

    typealias E = T
    func subscribe<O:ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return origin
            .do(
                onError: { [unowned self] err in self.errorsSubject.on(.next(err))  }
            )
            .retryWhen{ errorsObservable in errorsObservable.flatMapLatest{ [unowned self] _ in self.recoverMeans } }
            .subscribe(observer)
    }

    private let origin: Observable<T>
    private let recoverMeans: Observable<Void>
    private let errorsSubject: PublishSubject<Swift.Error>
    init<ObservableOrigin: ObservableType, ObservableVoid: ObservableType>(
        origin: ObservableOrigin,
        recoveringOn recoverMeans: ObservableVoid,
        reportingErrorsTo errorsSubject: PublishSubject<Swift.Error>) where ObservableOrigin.E == T, ObservableVoid.E == Void {
        self.origin = origin.asObservable()
        self.recoverMeans = recoverMeans.asObservable()
        self.errorsSubject = errorsSubject
    }

}
