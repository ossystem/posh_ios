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
    var poshiks: [Poshik] = []
    var bag = DisposeBag()
    let myPoshiksService = MyPoshiksService()
    var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        addButton.delegate = self
        addButton.type = .above
        addButton.subButtons = [
            RoundedButton.button(with: #imageLiteral(resourceName: "icon_vk-1"), target: self, action: #selector(addTextImage)),
            RoundedButton.button(with: #imageLiteral(resourceName: "icon_fb-1"), target: self, action: #selector(addTextImage)),
            RoundedButton.button(with: #imageLiteral(resourceName: "instagram"), target: self, action: #selector(addTextImage)),
            RoundedButton.button(with: #imageLiteral(resourceName: "icon_snapchat"), target: self, action: #selector(addTextImage)),
            RoundedButton.button(with: #imageLiteral(resourceName: "icon_text"), target: self, action: #selector(addTextImage)),
            RoundedButton.button(with: #imageLiteral(resourceName: "icon_phone"), target: self, action: #selector(addTextImage)),
        ]

        blurView = UIVisualEffectView(frame: view.bounds)
        myPoshiksService.getPoshiks().subscribe(onNext: {
            poshiks in
            self.poshiks = poshiks.poshiks
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
        cell.configure(with: poshiks[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return poshiks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let poshik = poshiks[indexPath.row]
        let frame = collectionView.cellForItem(at: indexPath)?.frame
        let model = PoshikViewModel(poshik: poshik, startingFrame: frame!)
        performSegue(withIdentifier: Identifiers.Segue.PoshikViewController, sender: model)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segue.PoshikViewController,
            let sender = sender as? PoshikViewModel,
            let poshikViewController = segue.destination as? PoshikViewController {
            poshikViewController.model = sender
        }
        
    }
    
    //MARK: expandable button delegate 
    
    func willExpand(_ button: ExpandableButton) {
        view.insertSubview(blurView, belowSubview: topBar)
        button.highlight(true)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView?.effect = UIBlurEffect(style: .extraLight)
            button.transform = CGAffineTransform(rotationAngle: CGFloat(135.0.degreesToRadians))
        })
    }
    
    func willShrink(_ button: ExpandableButton) {
        button.highlight(false)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.effect = nil
            button.transform = .identity
        },completion: { completed in
            self.blurView.removeFromSuperview()
        })
    }
    
    
}
