//
//  UILabel+Extension.swift
//  piscum.photos
//
//  Created by Danial Fajar on 05/06/2022.
//

import UIKit

extension UILabel {
    func changeCertainTextColor (fullText: String, changeText: String, color: UIColor = UIColor(named: "Label Color") ?? .black, font: UIFont? = nil) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText, options: .caseInsensitive)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        
        if font != nil {
            attribute.addAttribute(.font, value: font ?? UIFont.systemFont(ofSize: 15), range: range)
        }
        
        self.attributedText = attribute
    }
}
