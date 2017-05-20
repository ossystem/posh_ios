//
//  RedactorTextField.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 15/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import IMGLYColorPicker

protocol RedactorTextFieldDelegate: class {
    func redactorTextField(_ redactorTextField: RedactorTextField, didSelectBackground color: UIColor)
    func completeCreatingImage()
}

class RedactorTextField: UITextView {
    
    weak var redactorDelegate: RedactorTextFieldDelegate?
    
    //TODO: set proper images
    //TODO: store all properties somewhere
    
    enum RedactorTabs: Int {
        case text = 0, font = 2, textColor = 4, fillColor = 6, ok = 8
    }
    var poshikBackgroundColor: UIColor?
    
    private var actualtKeyBoardHeight: CGFloat = 216
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.white
        toolBar.sizeToFit()
        
        let textButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_keyboard_pink"), style: .plain, target: self, action: #selector(beginTextChanging))
        let fontButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_font_pink"), style: .plain, target: self, action: #selector(beginFontSelection))
        let textColorButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_font_color_pink"), style: .plain, target: self, action: #selector(beginTextColorSelection))
        let backgroundColorButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_fill_pink"), style: .plain, target: self, action: #selector(beginBackgroundColorSelection))
        let doneButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_text"), style: .done, target: self, action: #selector(createImage))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.tintColor = UIColor.Kulon.pink
        toolBar.setItems([textButton, spaceButton, fontButton, spaceButton, textColorButton, spaceButton, backgroundColorButton, spaceButton, doneButton], animated: false)
        
        self.inputAccessoryView = toolBar
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        beginTextChanging()
    }
    
    func beginTextColorSelection() {
        selectBarButton(.textColor)
        let colorPicker = ColorPickerView()
        colorPicker.addTarget(self, action: #selector(textColorPicked(_:)), for: .valueChanged)
        colorPicker.frame = CGRect(x: 0, y: 0, width: 0, height: actualtKeyBoardHeight)
        colorPicker.color = textColor ?? .white
        changeInputView(to: colorPicker)
    }
    
    func beginBackgroundColorSelection() {
        selectBarButton(.fillColor)
        let colorPicker = ColorPickerView()
        colorPicker.addTarget(self, action: #selector(backgroundColorPicked(_:)), for: .valueChanged)
        colorPicker.frame = CGRect(x: 0, y: 0, width: 0, height: actualtKeyBoardHeight)
        colorPicker.color = poshikBackgroundColor ?? .lightGray
        changeInputView(to: colorPicker)
    }
    
    func beginFontSelection() {
        selectBarButton(.font)
    }
    
    func beginTextChanging() {
        selectBarButton(.text)
        changeInputView(to: nil)
    }
    
    func createImage() {
        redactorDelegate?.completeCreatingImage()
    }
    
    private func changeInputView(to view: UIView?) {
        inputView = view
        reloadInputViews()
    }
    
    private func selectBarButton(_ id: RedactorTabs) {
        guard let toolBar = inputAccessoryView as? UIToolbar,
            let items = toolBar.items,
            items.count > id.rawValue
            else { return }
        
        for (index, item) in items.enumerated() {
            if index != id.rawValue {
                item.tintColor = UIColor.Kulon.pink
            } else {
                item.tintColor = UIColor.Kulon.orange
            }
        }
    }
    
    //MARK: - colorPickerDelegate
    
    func textColorPicked(_ colorPickerView: ColorPickerView) {
        textColor = colorPickerView.color
    }
    
    func backgroundColorPicked(_ colorPickerView: ColorPickerView) {
        poshikBackgroundColor = colorPickerView.color
        redactorDelegate?.redactorTextField(self, didSelectBackground: colorPickerView.color)
    }
    
    func keyBoardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        actualtKeyBoardHeight = keyboardRectangle.height - inputAccessoryView!.frame.height
    }
    
}
