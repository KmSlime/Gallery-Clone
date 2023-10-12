//
//  UIRadioButtonController.swift
//  GlueTeam
//
//  Created by LIEMNH on 12/10/2023.
//

import UIKit

class RadioButtonController: NSObject {
    
    private var selectedColor: UIColor?
    private var normalColor: UIColor?
    private var selectedIcon: UIImage?
    private var normalIcon: UIImage?
    var buttonsArray: [UIButton]! {
        didSet {
            for button in buttonsArray {
                button.setImage(selectedIcon, for: .selected)
                button.setTitleColor(selectedColor, for: .selected)
                button.setImage(normalIcon, for: .normal)
                button.setTitleColor(normalColor, for: .normal)
                if selectedIcon != nil || normalIcon != nil {
                    button.setPaddingImage()
                }
            }
        }
    }
    
    var selectedButton: UIButton?
    var defaultButton: UIButton = UIButton() {
        didSet {
            buttonArrayUpdated(buttonSelected: self.defaultButton)
        }
    }
    
    init(selectedTitleColor: UIColor, normalTitleColor: UIColor, selectedIcon: UIImage? = nil, normalIcon: UIImage? = nil) {
        self.selectedColor = selectedTitleColor
        self.normalColor = normalTitleColor
        self.normalIcon = normalIcon
        self.selectedIcon = selectedIcon
    }

    func buttonArrayUpdated(buttonSelected: UIButton) {
        for button in buttonsArray {
            if button == buttonSelected {
                selectedButton = button
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }
}
