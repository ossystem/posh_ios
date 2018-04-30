//
//  TabBarController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 29/04/2018.
//  Copyright © 2018 Jufy. All rights reserved.
//

import Foundation
import RxSwift

class TabBarController: UITabBarController {
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let purchasesVC = (viewControllers?[1] as? UINavigationController)?.viewControllers.first  as? MyImagesViewController {

        }
    }
    
    func showArtist(_ artist: Artist) {
        if selectedIndex == 0 {
            (selectedViewController as? UINavigationController)?.popToRootViewController(animated: true)
        } else {
            self.selectedIndex = 0
        }
        ((selectedViewController as? UINavigationController)?.viewControllers.first as? StoreViewController)?.showArtist(artist)
    }
}
