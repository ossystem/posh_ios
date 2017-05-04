//
//  EspandableButton.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 02/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

class ExpandableButton: RoundedButton {
    var buttonAction: ButtonActionType? {
        didSet {
            if buttonAction != nil {
                addTarget(self, action: #selector(performAction), for: .touchUpInside)
            } else {
                removeTarget(self, action: #selector(performAction), for: .touchUpInside)
            }
        }
    }
    
    var expanrionRadius: CGFloat = 100
    
    func performAction() {
        guard let buttonAction = buttonAction else{ return }
        switch buttonAction {
        case let .simpleAction(action):
            action()
        case let .multipleButtons(buttons):
            let angleStep = 180.0/(CGFloat(buttons.count) + 1.0)
            for (index, button) in buttons.enumerated() {
                var newFrame = self.frame
                newFrame.origin.x -= expanrionRadius * cos(angleStep.degreesToRadians * CGFloat(index + 1))
                newFrame.origin.y += expanrionRadius * sin(angleStep.degreesToRadians * CGFloat(index + 1))
                button.frame = newFrame
                button.backgroundColor = UIColor.black
                self.addSubview(button)
            }
        }
    }
    
    
}
