//
//  Paginable.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 23/08/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import RxSwift


class PaginableAndRefreshablePoshiksFromMarket: ObservableType, Parametrized {
    
    typealias E = [Poshik]
    
    var page: Int = 1
    let pageSize: Int = 19
    var lastPage: Bool = false
    
    var elements: [Poshik] = []
    
    private let refreshControl: UIRefreshControl

    var parameter: Variable<ParameterType> {
        return origin.parameter
    }
    
    var origin: PoshiksFromMarket
    
    func subscribe<O:ObserverType>(_ observer: O) -> Disposable where O.E == E {
        
        return refreshControl.rx.controlEvent(.valueChanged).asObservable().startWith(()) //Begin execution immidiately
            .flatMapLatest{ [unowned self] () -> Observable<[Poshik]> in
                self.refresh()
                return self.origin
                    .map { [unowned self] in
                        if $0.count == 0 {
                            self.lastPage = true
                        } else {
                            self.elements += $0
                        }
                        return self.elements
                    }
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
    
    init(updatedOn refreshControl: UIRefreshControl) {
        origin = PoshiksFromMarket()
        self.refreshControl = refreshControl
    }
    
    
    func loadNextPageIfNeeded(for id: IndexPath) {
        if !lastPage && id.row == (page * pageSize)-1 {
            page += 1
            var value = parameter.value as! PaginationParameter
            value.page = page
            origin.update(parameterValue: value as! ParameterType)
        }
    }
    
    func refresh() {
        lastPage = false
        page = 1
        elements = []
        var value = parameter.value as! PaginationParameter
        value.page = page
        origin.update(parameterValue: value as! ParameterType)
    }
    
    func update(parameterValue: ParameterType) {
        lastPage = false
        page = 1
        elements = []
        var value = parameterValue as! PaginationParameter
        value.page = page
        origin.update(parameterValue: value as! ParameterType)
    }
}
