//
//  Refreshable.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 23/08/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import RxSwift

class RefreshableByRefreshControl<T>: ObservableType {
    
    typealias E = T
    func subscribe<O:ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return refreshControl.rx.controlEvent(.valueChanged).asObservable().startWith(()) //Begin execution immidiately
            .flatMapLatest{ [unowned self] in
                return self.origin
            }
            .do(
                onNext: { [unowned self] _ in
                    self.refreshControl.endRefreshing()
                },
                onError: { [unowned self] _ in
                    self.refreshControl.endRefreshing()
                }
            )
            .subscribe(observer)
    }
    
    private let refreshControl: UIRefreshControl
    private let origin: Observable<T>
    init<ObservableOrigin: ObservableType>(origin: ObservableOrigin, updatedOn refreshControl: UIRefreshControl) where ObservableOrigin.E == T {
        self.origin = origin.asObservable()
        self.refreshControl = refreshControl
    }
    
}
