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
    @objc optional func willExpand(_ button: ExpandableButton)
    @objc optional func didExpand(_ button: ExpandableButton)
    @objc optional func willShrink(_ button: ExpandableButton)
    @objc optional func didShrink(_ button: ExpandableButton)
}

class ExpandableButton: UIView {

    @IBOutlet weak var mainButton: UIButton!
    var subButtons: [UIButton]!
    
    private var isExpanded = false
    
    var delegate: ExpandableButtonDelegate?
    var expansionDuration = 0.3
    var expansionRadius: CGFloat = 100
    
    override func awakeFromNib() {
        mainButton.addTarget(self, action: #selector(performAction), for: .touchUpInside)
    }

    func performAction() {
        if !isExpanded {
            
                //TODO: move to delegate
//            blurView = UIVisualEffectView(frame: superview!.bounds)
//            superview?.addSubview(blurView!)
//            UIView.animate(withDuration: 0.3, animations: {
//                self.blurView?.effect = UIBlurEffect(style: .extraLight)
//            })
            delegate?.willExpand?(self)
            
            let angleStep = 180.0 / (CGFloat(subButtons.count) + 1.0)
            for (index, button) in subButtons.enumerated() {
                var newFrame = self.mainButton.frame
                
                button.frame = newFrame
                newFrame.origin.x -= expansionRadius * cos(angleStep.degreesToRadians * CGFloat(index + 1))
                newFrame.origin.y += expansionRadius * sin(angleStep.degreesToRadians * CGFloat(index + 1))
                button.layer.cornerRadius = self.mainButton.frame.size.width / 2.0
                self.addSubview(button)
                UIView.animate(withDuration: 0.3, animations: {
                    button.frame = newFrame
                })
            }
            bringSubview(toFront: mainButton)
            //TODO: syncronize all animations andd add didExpand: method
            superview?.bringSubview(toFront: self)
            isExpanded = true
        } else {
            delegate?.willShrink?(self)
            UIView.animate(withDuration: 0.3, animations: {
//                self.blurView?.effect = nil
                for button in self.subButtons {
                    var frame = button.frame
                    frame.origin = self.mainButton.frame.origin
                    button.frame = frame
                }
            }, completion: { completed in
//                self.blurView?.removeFromSuperview()
                for button in self.subButtons {
                    button.removeFromSuperview()
                }
                self.delegate?.didShrink?(self)
            })
            isExpanded = false
        }
        
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isExpanded {
            for button in subButtons {
                if let convertedPoint = superview?.convert(point, to: self), button.frame.contains(convertedPoint) {
                    return true
                }
            }
        }
        return super.point(inside: point, with: event)
    }
}
