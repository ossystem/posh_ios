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
    var bag = DisposeBag()
    let myPoshiksService = MyPoshiksService()
    var blurView: UIVisualEffectView!
    
    class MyImagesSectionTitles {
        
        private var hasMy = false
        private var hasPurchased = false
        var titles: [String] {
            var sections = [String]()
            if hasMy { sections.append("My images") }
            if hasPurchased { sections.append("Purchases") }
            return sections
        }
        var count: Int {
            return (hasMy ? 1 : 0) + (hasPurchased ? 1 : 0)
        }
        var purchasesIndex: Int {
            return count - 1
        }
        var myIndex: Int {
            return (hasMy ? 1 : 0) - 1
        }
        
        func loadedMy(poshiks: [Poshik]) {
            hasMy = poshiks.count > 0
        }
        
        func loadedPurchased(poshiks: [Poshik]) {
            hasPurchased =  poshiks.count > 0
        }
        
        
        
    }
    
    private let sectionTitles = MyImagesSectionTitles()
    
    override func viewDidLoad() {
        addButton.rx.tap.subscribe(onNext: {
            self.addTextImage()
        }).disposed(by: bag)
        collectionView.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0)

        topBar.button.rx.tap.subscribe(onNext: {
            self.addTextImage()
        }).disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        loadData()
    }
    
    func loadData() {
        blurView = UIVisualEffectView(frame: view.bounds)
        myPoshiksService.getMyPoshiks().subscribe(onNext: {
            poshiks in
            self.myPoshiks = poshiks.poshiks
            self.sectionTitles.loadedMy(poshiks: poshiks.poshiks)
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
        headerView.configure(with: sectionTitles.titles[indexPath.section])
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


