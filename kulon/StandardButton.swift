//
//  StandardButton.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 21/05/2018.
//  Copyright © 2018 Jufy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class StandardButton: UIButton {
    private var disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        rx.controlEvent(.touchDown).subscribe(onNext: { [unowned self] in
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.5) ?? nil
            self.titleLabel?.alpha = 0.8
        }).disposed(by: disposeBag)
        
        rx.controlEvent([.touchCancel, .touchUpOutside, .touchUpInside]).subscribe(onNext: { [unowned self] in
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(1) ?? nil
            self.titleLabel?.alpha = 1
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
