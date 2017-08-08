//
//  Button.swift
//  pyunrihae
//
//  Created by woowabrothers on 2017. 8. 8..
//  Copyright © 2017년 busride. All rights reserved.
//

import Foundation
import UIKit

class Button{
    static func select(btn: UIButton){
        let color = UIColor(red: CGFloat(Float(0xE3) / 255.0), green: CGFloat(Float(0x4B) / 255.0),  blue: CGFloat(Float(0x0A) / 255.0), alpha: CGFloat(Float(1)))
        btn.isSelected = true
        btn.setTitleColor(color, for: .selected)
    }
    static func changeColor(btn: UIButton, color: UIColor, imageName: String){
        let origImage = UIImage(named: imageName);
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btn.setImage(tintedImage, for: .normal)
        btn.tintColor = color
    }
}
