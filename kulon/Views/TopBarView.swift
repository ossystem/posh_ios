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
    case simpleAction(()->())
    case multipleButtons([UIButton])
}

class TopBarView: UIView {
    
    @IBOutlet weak var background: TopBarBackgroundView!
    @IBOutlet weak var button: ExpandableButton!
    
    var buttonAction: ButtonActionType?
    
}
