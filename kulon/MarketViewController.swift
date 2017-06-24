 //
//  SecondViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 19/04/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import UIKit
import RxBluetoothKit
import RxSwift

class StoreViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, ExpandableButtonDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var categoriesTableView: UITableView! {
        didSet {
            categoriesTableView.delegate = self
            categoriesTableView.dataSource = self
        }
    }
    @IBOutlet weak var topButton: ExpandableButton!
    @IBOutlet weak var tagInputView: UIView!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var tagBottomConstraint: NSLayoutConstraint!

    
    private let bleService = BLEService.shared
    private var blurView: UIVisualEffectView!
    private let marketService = MarketService()
    
    var bag: DisposeBag = DisposeBag()
    var poshiks: [Poshik] = []
    var categories: [PoshikCategory] = []
    var marketParameter =  MarketParameter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topButton.delegate = self
        
        //TODO: try to rewrite using rx
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        categoriesTableView.contentInset = UIEdgeInsets(top: 140, left: 0, bottom: 0, right: 0)
        categoriesTableView.tableFooterView = UIView() //hack to remove emty cells
        
        //--------- на всякий случай а то че то не спервого раза
        loadData()
        loadData()
        loadData()
        loadData()
        //----------
    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInterface()
        loadData()
        
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
    
    func loadData() {
        marketService.getPoshiks(parameter: marketParameter)
            .subscribe(onNext: {
                poshiks in
                self.poshiks = poshiks.poshiks
                self.collectionView.reloadData()
            }, onError: {
                error in
                print(error.localizedDescription)
            }).addDisposableTo(bag)
        
    }
    
    func loadCategories() {
        marketService.getCategories().subscribe(onNext: { categories in
            self.categories = categories.categories
            self.categoriesTableView.reloadData()
        }).addDisposableTo(bag)
    }
    
    func searchTags() {
        statrSearching()
    }
    
    func searchCategories() {
        startCategorySelection()
    }
    
    private func statrSearching() {
        endCategorySelection()
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
        endSearching()
        loadCategories()
        categoryButton.highlight(true)
        categoryButton.backgroundColor = UIColor.Kulon.orange
        categoriesTableView.isHidden = false
    }
    
    private func endCategorySelection() {
        categoryButton.highlight(false)
        categoryButton.backgroundColor = .white
        categoriesTableView.isHidden = true
    }
    
    func didSelect(category: PoshikCategory) {
        topButton.hideButtons()
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
    
    //MARK: - Expandable button delegate
    
    func willExpand(_ button: ExpandableButton) {
        view.insertSubview(blurView, aboveSubview: collectionView)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView?.effect = UIBlurEffect(style: .extraLight)
        }, completion: { _ in
                self.statrSearching()
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
    
    //MARK: - tableView 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cell.categoryCell) as! CategoryCell
        cell.configure(with: categories[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelect(category: categories[indexPath.row])
    }

}

