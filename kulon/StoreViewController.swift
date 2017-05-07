 //
//  SecondViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 19/04/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import UIKit
import RxBluetoothKit

class StoreViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, ExpandableButtonDelegate {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    let bleService = BLEService.shared
    
    var blurView: UIVisualEffectView!
    
    //MARK: - Lifecycle
    //c 2A37 s 180D
    //  2A29   180A
    override func viewDidLoad() {
        super.viewDidLoad()
        topBar.button.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInterface()
        
    }
    
    func discover() {
        bleService.discover()
    }
    
    let categoryButton = RoundedButton()
    let tagButton = RoundedButton()

    
    func setupInterface(){
        categoryButton.setImage(#imageLiteral(resourceName: "icon_camera"), for: .normal)
        categoryButton.backgroundColor = UIColor.Kulon.orange
        categoryButton.addTarget(self, action: #selector(searchCategories), for: .touchUpInside)
        tagButton.setImage(#imageLiteral(resourceName: "icon_camera"), for: .normal)
        tagButton.setImage(#imageLiteral(resourceName: "icon_password"), for: .highlighted)
        tagButton.backgroundColor = UIColor.Kulon.orange
        tagButton.addTarget(self, action: #selector(searchTags), for: .touchUpInside)
        topBar.button.subButtons = [categoryButton, tagButton]
        
        blurView = UIVisualEffectView(frame: view.bounds)
        view.addSubview(blurView!)
        blurView.isHidden = true
        view.bringSubview(toFront: topBar)
    }
    
    func searchTags() {
        tagButton.isHighlighted = true
    }
    
    func searchCategories() {
        
    }
    
    //MARK: - Collection view datasource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    //MARK: - Expandable button delegate
    
    func willExpand(_ button: ExpandableButton) {
        blurView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView?.effect = UIBlurEffect(style: .extraLight)
        })
    }
    
    func willShrink(_ button: ExpandableButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.effect = nil
        },completion: { completed in
            self.blurView.isHidden = true
        })
    }

}
