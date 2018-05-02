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

    private let balanceService = BalanceService()
    private var balance: Variable<BalanceTo> = Variable<BalanceTo>(BalanceLoading().toBalance())
    
    private let disposeBag = DisposeBag()
    
    private let ownedArtworks: OwnedArtworks = OwnedArtworksFromAPI()
    private let likedArtworks: MarketableArtworks = LikedArtworksFromAPI()
    private var refreshableArtworks: RefreshableByRefreshControl<([OwnedArtwork])>!
    private var refreshableBalance: RefreshableByRefreshControl<BalanceTo>!
    private let refreshControl = UIRefreshControl()
    
    
    private var artistSubject = PublishSubject<Artist>()
    var wantsToShowArtist: Observable<Artist> {
        return artistSubject.debug()
    }
    
    override func viewDidLoad() {
        
        collectionView.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0)
        collectionView.refreshControl = refreshControl
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<StandardSectionModel<Artwork>>()
        dataSource.configureCell = { ds, cv, ip, artwork in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: Identifiers.Cell.poshikCell, for: ip) as! PoshikCell
            cell.configure(with: artwork)
            return cell
        }
        
        dataSource.supplementaryViewFactory = { [unowned self] ds, cv, kind, ip in
            let view = cv.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: ip) as! CollectionHeaderView
            view.configure(with: self.balance.value.toString())
            return view
        }
        
        refreshableArtworks = RefreshableByRefreshControl(origin: ownedArtworks.asObservable().catchErrorJustReturn([]), updatedOn: refreshControl)
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

        
        collectionView.rx.modelSelected((Artwork & Selectable).self)
            .do(onNext: {
                [unowned self] in
                self.navigationController?.pushViewController( $0.viewControllerToPresentt, animated: true)
            })
            .flatMap {
                ($0.viewControllerToPresentt as! OwnedArtworkController).wantsToShowArtist.asObservable()
            }
            .debug()
            .bind(to: artistSubject).disposed(by: disposeBag)
        

        refreshableBalance = RefreshableByRefreshControl(origin: balanceService.balance()
            .map { $0.toBalance() }
            .startWith(BalanceLoading().toBalance())
            .catchErrorJustReturn(BalanceFromValue(value: 0).toBalance()), updatedOn: refreshControl)
        
        refreshableBalance
        .do(onNext: { [unowned self] _ in self.collectionView.reloadData() })
        .bind(to: balance).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshableArtworks.refresh()
        refreshableBalance.refresh()
    }
    
}


