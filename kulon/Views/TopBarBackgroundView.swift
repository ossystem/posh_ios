//
//  TopBarBackgroundView.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 20/04/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TopBarBackgroundView: UIView {
    
    @IBInspectable var mainColor: UIColor = .white
    @IBInspectable var shadowSize: CGFloat = 3.0
    @IBInspectable var shadowColor: UIColor = .black
    @IBInspectable var topOffsetHeight: CGFloat = 24
    ///In degrees
    @IBInspectable var angle: CGFloat = 20
    @IBInspectable var buttonRadius: CGFloat = 27
        
    override func draw(_ rect: CGRect) {
        let outterPath = outterRadialBacground(for: rect)
        let buttonPath = buttonBackground(for: rect)
        
        outterPath.append(buttonPath)
        let shapeLayer = CAShapeLayer()
        shapeLayer.rasterizationScale = UIScreen.main.scale * 2
        shapeLayer.shouldRasterize = true
        shapeLayer.shadowOpacity = 0.1
        shapeLayer.shadowRadius = shadowSize
        shapeLayer.shadowOffset = CGSize(width: 0, height: 0)
        shapeLayer.path = outterPath.cgPath
        shapeLayer.fillColor = mainColor.cgColor
        layer.addSublayer(shapeLayer)
    }
    
    private func outterRadialBacground(for rect: CGRect) -> UIBezierPath {
        let radius = (rect.width / 2) / sin(angle.degreesToRadians/2)
        let centerY = topOffsetHeight - (rect.width/2) / tan(angle.degreesToRadians/2)
        let centerX = rect.width / 2
        let center = CGPoint(x: centerX, y: centerY)
        let startAngle = (CGFloat.pi - angle) / 2
        let endAngle = (CGFloat.pi + angle) / 2
        let backgroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        return backgroundPath
    }
    
    private func buttonBackground(for rect: CGRect) -> UIBezierPath {
        let centerX = rect.width / 2
        let R = (rect.width / 2) / sin(angle.degreesToRadians/2)
        let bigCenter = topOffsetHeight - (rect.width/2) / tan(angle.degreesToRadians/2)
        let centerY = bigCenter + sqrt(pow(R, 2) - pow(buttonRadius, 2))//topOffsetHeight + 16
        let center = CGPoint(x: centerX, y: centerY)
        let buttonbackgroundPath = UIBezierPath(arcCenter: center, radius: buttonRadius, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
        return buttonbackgroundPath
    }
    
}
