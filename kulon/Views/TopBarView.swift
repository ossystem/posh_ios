//
//  TopBarView.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 19/04/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

enum ButtonActionType {
    case simpleAction(() -> ())
    case multipleButtons([UIButton])
}

class TopBarView: UIView {

    @IBOutlet weak var background: TopBarBackgroundView!
    @IBOutlet weak var button: ExpandableButton!
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        var view = super.hitTest(point, with: event)
//        if view == nil {
//            if button.point(inside: point, with: event) {
//                view = button
//            }
//        }
//        return view
//    }
    
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        return background.point(inside: point, with: event) || button?.point(inside: point, with:event)
//    }
}
