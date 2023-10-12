//
//  LoadingManager.swift
//  GlueTeam
//
//  Created by LIEMNH on 12/10/2023.
//

import UIKit

final class LoadingManager: UIView {
    
    public static let shared = LoadingManager()
    private var indicator: UIActivityIndicatorView?
    private var containerView: UIView?
    private var isShowing = false
    
    func show() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow, !self.isShowing {
                if self.indicator == nil || self.containerView == nil {
                    self.indicator = UIActivityIndicatorView(style: .whiteLarge)
                    self.indicator?.color = UIColor.gray
                    self.containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                    self.containerView!.addSubview(self.indicator!)
                    self.indicator!.center = self.containerView!.center
                }
                self.isShowing = true
                window.addSubview(self.containerView!)
                self.indicator?.startAnimating()
            }
        }
    }
    
    func hide() {
        DispatchQueue.main.async {
            self.isShowing = false
            self.indicator?.stopAnimating()
            self.containerView?.removeFromSuperview()
        }
    }
}
