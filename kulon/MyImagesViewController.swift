//
//  FavoritesViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 22/04/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import RxBluetoothKit
import RxSwift
import CoreBluetooth
import RxDataSources
class MyImagesViewController: BaseViewController, ExpandableButtonDelegate {
    
    @IBOutlet weak var addButton: RoundedButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var myPoshiks: [Poshik] = []
    var purchasedPoshiks: [Poshik] = []
    var bag = DisposeBag()
    let balanceService = BalanceService()
    
    class MyImagesSectionTitles {
        
        var balance: Variable<BalanceTo> = Variable<BalanceTo>(BalanceLoading().toBalance())
        
        subscript(index: Int) -> String {
            get {
                if index == 0 {
                    return "Balance: \(balance.value.toString())"
                }
                return titles[index]
            }
        }
        
        private var hasFavorite = true
        private var hasPurchased = true
        var titles: [String] {
            var sections = [String]()
            sections.append("Balance: Loading")
            if hasPurchased { sections.append("Purchases") }
            if hasFavorite { sections.append("Favorite") }
            return sections
        }
        //TODO: I think it is needed to be refactor
        var count: Int {
            return 1 + (hasFavorite ? 1 : 0) + (hasPurchased ? 1 : 0)
        }
        var myIndex: Int {
            return count - 1
        }
    }
    
    private let sectionTitles = MyImagesSectionTitles()
    
    private let disposeBag = DisposeBag()
    
    private let ownedArtworks: OwnedArtworks = OwnedArtworksFromAPI()
    private let likedArtworks: MarketableArtworks = LikedArtworksFromAPI()
    
    override func viewDidLoad() {
        
        collectionView.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0)
        
        let refreshControl = UIRefreshControl()
        
        collectionView.refreshControl = refreshControl
        

        
        let dataSource = RxCollectionViewSectionedReloadDataSource<StandardSectionModel<Artwork>>()
        dataSource.configureCell = { ds, cv, ip, artwork in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: Identifiers.Cell.poshikCell, for: ip) as! PoshikCell
            cell.configure(with: artwork)
            return cell
        }
        
        dataSource.supplementaryViewFactory = { [unowned self] ds, cv, kind, ip in
            let view = cv.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: ip) as! CollectionHeaderView
            view.configure(with: self.sectionTitles[ip.section])
            return view
        }
        
        //TODO: make refresh
        RefreshableByRefreshControl(origin: Observable.combineLatest(ownedArtworks.asObservable()
                                                                     .catchErrorJustReturn([]),
                                                                     likedArtworks.asObservable()
                                                                     .catchErrorJustReturn([])),
                                    updatedOn: refreshControl)
            .debug()
            .map {
                [StandardSectionModel<Artwork>(items: []),
                 StandardSectionModel<Artwork>(items: $0),
                 StandardSectionModel<Artwork>(items: $1)]
            }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        
        collectionView.rx.modelSelected((Artwork & Selectable).self).subscribe(onNext: {
             self.navigationController?.pushViewController( $0.viewControllerToPresentt, animated: true)
        }).disposed(by: disposeBag)

        
        balanceService.balance()
            .map { $0.toBalance() }
            .startWith(BalanceLoading().toBalance())
            .catchErrorJustReturn(BalanceFromValue(value: 0).toBalance())
            .do(onNext: { [unowned self] _ in self.collectionView.reloadData() })
        .bind(to: sectionTitles.balance).disposed(by: disposeBag)
    }

    
}


