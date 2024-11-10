//
//  UIView.swift
//  spyneAssignment
//
//  Created by sunil biloniya on 10/11/24.
//

import Foundation
import UIKit

extension UITableView {
    func setBackgroundMessage(_ message: String?, color: UIColor? = UIColor.gray) {
        if let message = message {
            // Display a message when the table is empty
            let messageLabel = UILabel()
            messageLabel.text = message
            //messageLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            messageLabel.font = UIFont.systemFont(ofSize: 16)
            messageLabel.textColor = color
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            messageLabel.sizeToFit()
            self.backgroundView = messageLabel
        } else {
            self.backgroundView = nil
        }
    }
}






 
