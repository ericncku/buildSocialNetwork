//
//  roundButton.swift
//  socialNetwork
//
//  Created by HOISIO LONG on 24/2/2017.
//  Copyright © 2017年 Eric Hoi. All rights reserved.
//

import UIKit

@IBDesignable

class RoundButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
        
    }
    
    override func prepareForInterfaceBuilder() {
        layer.cornerRadius = cornerRadius
    }
    
    
}
