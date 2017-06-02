//
//  FAQViewController.swift
//  TelemedDoctor
//
//  Created by Артмеий Шлесберг on 22/12/2016.
//  Copyright © 2016 Jufy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class FAQViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 120
            tableView.contentInset = UIEdgeInsets(top: 74, left: 0, bottom: 0, right: 0)
        }
    }
    
    private var questions = [CommonQuestion]()
    private var faqService = FAQSettingsService()
    private var expandedCellIndex: Int?
    private var bag = DisposeBag()
    
    //MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
    }
    
    //MARK: - Workflow
    
    private func loadData() {
        faqService.getQuestions().subscribe(onNext: {
                [weak self] questions in
                self?.questions = questions.questions
                self?.tableView.reloadData()
            }, onError: {
                [weak self] error in
                self?.showErrorMessage(error)
        }).addDisposableTo(bag)
    }
    
    private func setupInterface() {
        loadData()
    }
    
    //MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let currentExpandedIndex = expandedCellIndex, currentExpandedIndex == indexPath.row {
            expandedCellIndex = nil
        } else {
            expandedCellIndex = indexPath.row
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cell.FAQ) as! CommonQuestionCell
        cell.setup(question: questions[indexPath.row])
        if let expandedIndex = expandedCellIndex, expandedIndex == indexPath.row {
            cell.expanded = true
        } else {
            cell.expanded = false
        }
        return cell
    }

    @IBAction func topButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
