//
//  EspandableButton.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 02/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

@objc protocol  ExpandableButtonDelegate {
    
//    func expandableButton(_ button: ExpandableButton, willShowButtonAt index: Int) -> UIButton
//    func expandableButton(_ button: ExpandableButton, didRecivedTapAt index: Int, for subButton: UIButton)
    
    @objc optional func willExpand(_ button: ExpandableButton)
    @objc optional func didExpand(_ button: ExpandableButton)
    @objc optional func willShrink(_ button: ExpandableButton)
    @objc optional func didShrink(_ button: ExpandableButton)
}

enum ExpandableButtonType {
    case above, below
}

class ExpandableButton: RoundedButton {

    var subButtons: [UIButton]!
    
    private var isExpanded = false
    
    var delegate: ExpandableButtonDelegate?
    var expansionDuration = 0.3
    var expansionRadius: CGFloat = 100
    var type: ExpandableButtonType = .below
    
    override func awakeFromNib() {
        addTarget(self, action: #selector(performAction), for: .touchUpInside)
    }

    func performAction() {
        if !isExpanded {
            showButtons()
        } else {
            hideButtons()
        }
    }
    
    func showButtons() {
        let angleStep = 180.0 / (CGFloat(subButtons.count) + 1.0)
        var newFrames: [CGRect] = []
        for (index, button) in subButtons.enumerated() {
            var newFrame = frame
            button.frame = newFrame
            switch type {
            case .above:
                newFrame.origin.x -= expansionRadius * cos(angleStep.degreesToRadians * CGFloat(index + 1))
                newFrame.origin.y -= expansionRadius * sin(angleStep.degreesToRadians * CGFloat(index + 1))
            case .below:
                newFrame.origin.x -= expansionRadius * cos(angleStep.degreesToRadians * CGFloat(index + 1))
                newFrame.origin.y += expansionRadius * sin(angleStep.degreesToRadians * CGFloat(index + 1))
            }
            newFrames.append(newFrame)
            button.layer.cornerRadius = frame.size.width / 2.0
            superview?.insertSubview(button, belowSubview: self)
        }
        delegate?.willExpand?(self)
        UIView.animate(withDuration: 0.3, animations: {
            for (button, frame) in zip(self.subButtons, newFrames) {
                button.frame = frame
            }
        })
        isExpanded = true
    }
    
    func hideButtons() {
        delegate?.willShrink?(self)
        UIView.animate(withDuration: 0.3, animations: {
            for button in self.subButtons {
                var frame = button.frame
                frame.origin = self.frame.origin
                button.frame = frame
            }
        }, completion: { completed in
            for button in self.subButtons {
                button.removeFromSuperview()
            }
            self.delegate?.didShrink?(self)
        })
        isExpanded = false
    }
}
