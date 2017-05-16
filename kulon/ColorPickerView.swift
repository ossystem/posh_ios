//
//  ColorPickerView.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 15/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

protocol ColorableInput: class {
//    func colorPicker(_ colorPicker: ColorPickerView, didSelect color: UIColor)
}

//class ColorPickerView: UIView {
//    
//    weak var delegate: ColorableInput?
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        initializeSubviews()
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        initializeSubviews()
//    }
//    
//    private func initializeSubviews() {
//        let xibFileName = "ColorPicker" 
//        let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)?[0] as! UIView
//        self.addSubview(view)
//        view.frame = self.bounds
//    }
//    
//    @IBAction func setColor(_ sender: Any) {
//        delegate?.colorPicker(self, didSelect: .orange)
//    }
//    
//}
