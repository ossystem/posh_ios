 //
//  SecondViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 19/04/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import UIKit
import RxBluetoothKit

class StoreViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    let bleService = BLEService.shared
    
    //MARK: - Lifecycle
    //c 2A37 s 180D
    //  2A29   180A
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInterface()
        topBar.button.addTarget(self, action: #selector(discover), for: .touchUpInside)
    }
    
    func discover() {
        bleService.discover()
    }
    
    func setupInterface(){
        let button1 = UIButton()
        button1.addTarget(self, action: #selector(searchTags), for: .touchUpInside)
        let button2 = UIButton()
        button2.addTarget(self, action: #selector(searchCategories), for: .touchUpInside)
        topBar.buttonAction = .multipleButtons([button1, button2])
    }
    
    func searchTags() {
        print("search tags")
    }
    
    func searchCategories() {
        print("search categories")
    }
    
    //MARK: - Collection view datasource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }

}

