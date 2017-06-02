//
//  CommonQuestionCell.swift
//  TelemedDoctor
//
//  Created by Ivan Grachev on 02/03/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import UIKit

class CommonQuestionCell: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet var answerBottomSpaceConstraint: NSLayoutConstraint!
    
    var expanded = false {
        didSet {
            answerBottomSpaceConstraint.isActive = expanded
            answerLabel.isHidden = !expanded
        }
    }

    func setup(question: CommonQuestion) {
        questionLabel.text = question.question
        answerLabel.text = question.answer
    }
    
}
