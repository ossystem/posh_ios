//
//  MarketViewModel.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 20/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import RxSwift

class MarketViewModel {
    var poshiks: [Poshik] = []
    var categories: [PoshikCategory] = []
    var marketParameter =  MarketParameter()
    
    
    var categoriesCount: Int {
        return categories.count
    }
    func category(for indexPath: IndexPath) -> PoshikCategory {
        return categories[indexPath.row]
    }
    
    var poshiksCount: Int {
        return poshiks.count
    }
    func poshik(for indexPath: IndexPath) -> Poshik {
        return poshiks[indexPath.row]
    }
}

class MarketPresentationModel {
    
    var model: MarketViewModel!
    var marketService = MarketService()
    var bag: DisposeBag = DisposeBag()

    func loadData() {
        marketService.getPoshiks(parameter: model.marketParameter)
            .subscribe(onNext: {
                poshiks in
                self.model.poshiks = poshiks.poshiks
                //TODO: update view with new model
                //self.collectionView.reloadData()
            }, onError: {
                error in
                print(error.localizedDescription)
            }).addDisposableTo(bag)
    }
    
    
}
