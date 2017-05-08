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
    var poshiks: [Poshik] = Poshik.sampleSet + Poshik.sampleSet + Poshik.sampleSet + Poshik.sampleSet + Poshik.sampleSet
    
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
        categoryButton.backgroundColor = UIColor.white
        categoryButton.addTarget(self, action: #selector(searchCategories), for: .touchUpInside)
        categoryButton.borderColor = .white
        categoryButton.cornerRadius = 25
        categoryButton.borderWidth = 4
        tagButton.setImage(#imageLiteral(resourceName: "icon_camera"), for: .normal)
        tagButton.backgroundColor = UIColor.Kulon.orange
        tagButton.borderColor = .white
        tagButton.cornerRadius = 25
        tagButton.borderWidth = 4
        tagButton.addTarget(self, action: #selector(searchTags), for: .touchUpInside)
        topBar.button.subButtons = [categoryButton, tagButton]
        
        blurView = UIVisualEffectView(frame: view.bounds)
    }
    
    func searchTags() {
        tagButton.isHighlighted = true
    }
    
    func searchCategories() {
        
    }
    
    //MARK: - Collection view datasource

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.Cell.poshikCell, for: indexPath) as! PoshikCell
        cell.configure(with: poshiks[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return poshiks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
    }
    
    //MARK: - Expandable button delegate
    
    func willExpand(_ button: ExpandableButton) {
        view.addSubview(blurView!)
        view.bringSubview(toFront: topBar)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView?.effect = UIBlurEffect(style: .extraLight)
        })
    }
    
    func willShrink(_ button: ExpandableButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.effect = nil
        },completion: { completed in
            self.blurView.removeFromSuperview()
        })
    }

}

