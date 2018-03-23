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

class MyImagesViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, ExpandableButtonDelegate {
    
    @IBOutlet weak var addButton: RoundedButton!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    var myPoshiks: [Poshik] = []
    var purchasedPoshiks: [Poshik] = []
    var balance: Balance = Balance()
    var bag = DisposeBag()
    let myPoshiksService = MyPoshiksService()
    let favoriteService = FavoritesApiService()
    let balanceService = BalanceService()
    var blurView: UIVisualEffectView!
    
    class MyImagesSectionTitles {
        
        var balance: Variable<Balance> = Variable<Balance>(Balance())
        
        subscript(index: Int) -> String {
            get {
                if index == 0 {
                    return "Balance: \(balance.value.toString())"
                }
                return titles[index]
            }
        }
        
        private var hasFavorite = false
        private var hasPurchased = false
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
        
        func loadedFavorite(poshiks: [Poshik]) {
            hasFavorite = poshiks.count > 0
        }
        
        func loadedPurchased(poshiks: [Poshik]) {
            hasPurchased =  poshiks.count > 0
        }
        
        
        
    }
    
    private let sectionTitles = MyImagesSectionTitles()
    
    override func viewDidLoad() {
        
        collectionView.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0)
        
        let refreshControl = UIRefreshControl()
        
        collectionView.refreshControl = refreshControl
        
        refreshControl.rx.controlEvent(.valueChanged).startWith(())
            .subscribe(onNext: { [unowned self] in
            self.loadData()
            refreshControl.endRefreshing()
        }).disposed(by: bag)
    }
    
    func loadData() {
        blurView = UIVisualEffectView(frame: view.bounds)
        favoriteService.request(parameter: ParameterNone()).subscribe(onNext: {
            poshiks in
            self.myPoshiks = poshiks.poshiks
            self.sectionTitles.loadedFavorite(poshiks: poshiks.poshiks)
            self.collectionView.reloadData()
        }, onError: {
            error in
            print("myPoshiks: \(error.localizedDescription)")
        }).addDisposableTo(bag)
        myPoshiksService.getPurchasedPoshiks().subscribe(onNext: {
            poshiks in
            self.purchasedPoshiks = poshiks.poshiks
            self.sectionTitles.loadedPurchased(poshiks: poshiks.poshiks)
            self.collectionView.reloadData()
        }, onError: {
            error in
            print("myPoshiks: \(error.localizedDescription)")
        }).addDisposableTo(bag)
        balanceService.balance()
            .do(onNext: { [unowned self ] _ in self.collectionView.reloadData() })
            .bind(to: sectionTitles.balance).addDisposableTo(bag)
    }
    
    func addTextImage() {
        performSegue(withIdentifier: "AddTextImageID", sender: nil)
    }
    //MARK: collectionView delegate
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.Cell.poshikCell, for: indexPath) as! PoshikCell
        cell.configure(with: poshik(for: indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! CollectionHeaderView
        headerView.configure(with: sectionTitles[indexPath.section])
        return headerView

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == sectionTitles.myIndex {
            return myPoshiks.count
        } else {
            return  purchasedPoshiks.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let frame = collectionView.cellForItem(at: indexPath)?.frame
        let model = PoshikViewModel(poshik: poshik(for: indexPath), startingFrame: frame!)
        performSegue(withIdentifier: Identifiers.Segue.PoshikViewController, sender: model)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segue.PoshikViewController,
            let sender = sender as? PoshikViewModel,
            let poshikViewController = segue.destination as? PoshikViewController {
            poshikViewController.model = sender
        }
        
    }
    
    private func poshik(for indexPath: IndexPath) -> Poshik {
        var poshik: Poshik
        if indexPath.section == sectionTitles.myIndex {
            poshik = myPoshiks[indexPath.row]
        } else {
            poshik = purchasedPoshiks[indexPath.row]
        }
        return poshik
    }
    
}


