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
    @IBOutlet weak var topButton: ExpandableButton!
    @IBOutlet weak var tagInputView: UIView!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var tagBottomConstraint: NSLayoutConstraint!
    
    let bleService = BLEService.shared
    var blurView: UIVisualEffectView!
    var poshiks: [Poshik] = Poshik.sampleSet + Poshik.sampleSet + Poshik.sampleSet + Poshik.sampleSet + Poshik.sampleSet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topButton.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInterface()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        topButton.hideButtons()
    }
    
    let categoryButton = RoundedButton.button(with: #imageLiteral(resourceName: "icon_top_category_red"), highlightIcon: #imageLiteral(resourceName: "icon_top_category_white"),target: self, action: #selector(searchCategories))
    let tagButton = RoundedButton.button(with: #imageLiteral(resourceName: "icon_top_tag"), highlightIcon: #imageLiteral(resourceName: "icon_top_tag_selected"), target: self, action: #selector(searchTags))

    
    func setupInterface(){
        topButton.subButtons = [
            categoryButton,
            tagButton
        ]
        blurView = UIVisualEffectView(frame: view.bounds)
    }
    
    func searchTags() {
        statrSearching()
        endCategorySelection()
    }
    
    func searchCategories() {
        startCategorySelection()
        endSearching()
    }
    
    private func statrSearching() {
        tagInputView.isHidden = false
        tagTextField.becomeFirstResponder()
        tagButton.highlight(true)
        tagButton.backgroundColor = UIColor.Kulon.orange
    }
    
    private func endSearching() {
        tagButton.highlight(false)
        tagButton.backgroundColor = .white
        view.endEditing(true)
        tagInputView.isHidden = true
    }
    
    private func startCategorySelection() {
        categoryButton.highlight(true)
        categoryButton.backgroundColor = UIColor.Kulon.orange
    }
    
    private func endCategorySelection() {
        categoryButton.highlight(false)
        categoryButton.backgroundColor = .white
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
        let poshik = poshiks[indexPath.row]
        performSegue(withIdentifier: Identifiers.Segue.PoshikViewController, sender: poshik)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segue.PoshikViewController,
            let poshik = sender as? Poshik,
            let poshikViewController = segue.destination as? PoshikViewController{
            
        }
        
    }
    
    //MARK: - Expandable button delegate
    
    func willExpand(_ button: ExpandableButton) {
        view.insertSubview(blurView, belowSubview: topBar)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView?.effect = UIBlurEffect(style: .extraLight)
        })
    }
    
    func willShrink(_ button: ExpandableButton) {
        endSearching()
        endCategorySelection()
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.effect = nil
        },completion: { completed in
            self.blurView.removeFromSuperview()
        })
    }
    
    //MARK: - keyboard events handling
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if tagBottomConstraint.constant == -49 {
                tagBottomConstraint.constant += keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if tagBottomConstraint.constant != -49 {
                tagBottomConstraint.constant -= keyboardSize.height
            }
        }
    }
    
    

}

