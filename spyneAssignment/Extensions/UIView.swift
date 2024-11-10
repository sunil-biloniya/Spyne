//
//  UIToastView.swift
//  spyneAssignment
//
//  Created by sunil biloniya on 10/11/24.
//

import Foundation

extension UIView {
    func makeToast(_ message: String, color: UIColor = UIColor.appButtonBgColor) {
        let containerView = UIView()
        //            containerView.backgroundColor = color.withAlphaComponent(0.6)
        containerView.backgroundColor = color
        containerView.alpha = 0
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        containerView.layer.borderWidth = 1
        if #available(iOS 13.0, *) {
            containerView.layer.borderColor = CGColor(red: 255/255, green: 150/255, blue: 0/255, alpha: 1)
        } else {
            // Fallback on earlier versions
        }
        let toastLabel = UILabel()
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font.withSize(12.0)
        toastLabel.text = message
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 20).isActive = true
        containerView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -20).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        containerView.addSubview(toastLabel)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        toastLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 7).isActive = true
        toastLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -7).isActive = true
        toastLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5).isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            containerView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                containerView.alpha = 0
            }, completion: { _ in
                containerView.removeFromSuperview()
            })
        })
    }
}
