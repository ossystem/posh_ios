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
    
    @IBOutlet weak var addButton: ExpandableButton!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    var poshiks: [Poshik] = Poshik.sampleSet + Poshik.sampleSet + Poshik.sampleSet + Poshik.sampleSet + Poshik.sampleSet
    var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        addButton.delegate = self
        addButton.type = .above
        addButton.subButtons = [
            RoundedButton.button(with: #imageLiteral(resourceName: "icon_camera"), target: self, action: #selector(addTextImage)),
            RoundedButton.button(with: #imageLiteral(resourceName: "icon_camera"), target: self, action: #selector(addTextImage)),
            RoundedButton.button(with: #imageLiteral(resourceName: "icon_camera"), target: self, action: #selector(addTextImage)),
            RoundedButton.button(with: #imageLiteral(resourceName: "icon_camera"), target: self, action: #selector(addTextImage)),
            RoundedButton.button(with: #imageLiteral(resourceName: "icon_camera"), target: self, action: #selector(addTextImage)),
            RoundedButton.button(with: #imageLiteral(resourceName: "icon_camera"), target: self, action: #selector(addTextImage)),
        ]
        blurView = UIVisualEffectView(frame: view.bounds)
    }
    
    func addTextImage() {
        performSegue(withIdentifier: "AddTextImageID", sender: nil)
    }
    //MARK: collectionView delegate
    
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
    
    //MARK: expandable button delegate 
    
    func willExpand(_ button: ExpandableButton) {
        view.insertSubview(blurView, belowSubview: topBar)
        button.highlight(true)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView?.effect = UIBlurEffect(style: .extraLight)
        })
    }
    
    func willShrink(_ button: ExpandableButton) {
        button.highlight(false)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.effect = nil
        },completion: { completed in
            self.blurView.removeFromSuperview()
        })
    }
    
    
}
