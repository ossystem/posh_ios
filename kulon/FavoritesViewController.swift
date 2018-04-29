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

class FavoritesViewController: BaseViewController, ExpandableButtonDelegate {
    
    @IBOutlet weak var addButton: RoundedButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let balanceService = BalanceService()
    var balance: Variable<BalanceTo> = Variable<BalanceTo>(BalanceLoading().toBalance())
    
    private let disposeBag = DisposeBag()
    
    private let likedArtworks: MarketableArtworks = LikedArtworksFromAPI()
    private var refreshableArtworks: RefreshableByRefreshControl<([MarketableArtwork])>!
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        
        collectionView.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0)
        collectionView.refreshControl = refreshControl
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<StandardSectionModel<Artwork>>()
        dataSource.configureCell = { ds, cv, ip, artwork in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: Identifiers.Cell.poshikCell, for: ip) as! PoshikCell
            cell.configure(with: artwork)
            return cell
        }
        
        refreshableArtworks = RefreshableByRefreshControl(origin: likedArtworks.asObservable().catchErrorJustReturn([]), updatedOn: refreshControl)
        refreshableArtworks
            .asObservable()
            .debug()
            .map {
                [
                    StandardSectionModel<Artwork>(items: $0)
                ]
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
            .bind(to: balance).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshableArtworks.refresh()
    }
    
}


