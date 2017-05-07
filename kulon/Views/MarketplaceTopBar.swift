//
//  MarketplaceTopBar.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 07/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

class MarketplaceTopBar : TopBarView {
    
    private var isExpanded = false
    private var blurView: UIVisualEffectView? {
        willSet {
            blurView?.removeFromSuperview()
        }
    }
    
    var buttons: [RoundedButton] = []
    
    
    

}
