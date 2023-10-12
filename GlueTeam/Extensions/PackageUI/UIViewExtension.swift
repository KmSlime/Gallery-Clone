//
//  UIViewExtension.swift
//  GlueTeam
//
//  Created by LIEMNH on 11/10/2023.
//

import UIKit

typealias EmptyCompletion = () -> (Void)

class LoadingOverlayView: UIView {
    var indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    var animationIconSize: CGFloat = 240
    
    init() {
        super.init(frame: UIScreen.main.bounds);
        indicator.frame = CGRect(origin: center, size: CGSize(width: animationIconSize, height: animationIconSize))
        addSubview(indicator)
        indicator.color = .gray
        indicator.center = center
        indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        indicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Computed Properties
@objc extension UIView {
    class func instanceFromNib() -> UIView {
        return UINib(nibName: String(describing: self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else { return nil }
            return UIColor(cgColor: cgColor)
        }
        set { layer.borderColor = newValue?.cgColor }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            guard let cgColor = layer.shadowColor else { return nil }
            return UIColor(cgColor: cgColor)
        }
        set { layer.shadowColor = newValue?.cgColor }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get { return layer.shadowOpacity }
        set { layer.shadowOpacity = newValue }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
}

// MARK: - Convenience Functions
@objc extension UIView {
    @objc func dismissPopupView(with duration: TimeInterval = 0.3, _ completion: EmptyCompletion? = nil) {
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.alpha = 0
        }, completion: { [weak self] _ in
            completion?()
            self?.removeFromSuperview()
        })
    }
    
    @objc func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
    
    
    func fit(with duration: TimeInterval = 0.0, subView: UIView?, complete: EmptyCompletion? = nil) {
        guard let subView = subView else { return }
        subView.alpha = 0
        addSubview(subView)
        
        UIView.animate(withDuration: duration, animations: {
            subView.alpha = 1
            subView.setEdgesConstraint(to: self)
        }, completion: { _ in
            complete?()
        })
    }
    
    func setGradient(with colors: [UIColor]) {
        guard !colors.isEmpty else { return debugPrint("Nothing to draw, return!") }
        layer.sublayers?.forEach { ($0 as? CAGradientLayer)?.removeFromSuperlayer() }
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }
    
    func setGradient(with colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint, locations: [NSNumber] = [0, 1]) {
        guard !colors.isEmpty else { return debugPrint("Nothing to draw, return!") }
        layer.sublayers?.forEach { ($0 as? CAGradientLayer)?.removeFromSuperlayer() }
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.endPoint = endPoint
        gradient.frame = bounds
        gradient.locations = locations
        gradient.startPoint = startPoint
        layer.insertSublayer(gradient, at: 0)
    }

    func roundCorner(_ radius: CGFloat, color: UIColor = .clear, width: CGFloat = 0) {
        layer.cornerRadius = radius
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.masksToBounds = true
    }
    
    func roundingCornerTopLeftRight() {
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 16, height: 16))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.layer.mask = shape
    }
    
    func roundingCornerBottomLeftRight() {
        let maskPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: [.bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: 16, height: 16))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.layer.mask = shape
    }
    
    func addGradientColor(colors: [CGColor]) {
        let layer = CAGradientLayer()
        layer.frame = self.bounds
        layer.colors = colors
        self.layer.insertSublayer(layer, at: 0)
    }
    
    func addGradientColor(colors: [CGColor], startPoints: CGPoint, endPoint: CGPoint, location: [NSNumber]) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colors
        gradient.locations = location
        gradient.startPoint = startPoints
        gradient.endPoint = endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    @discardableResult
    func getGradient(colours: [UIColor], locations: [NSNumber]? = nil, opacity: Float = 1) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.opacity = opacity
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }

    func applyGradient(colours: [UIColor], locations: [NSNumber]?, isHorizontal: Bool = false) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        if isHorizontal {
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        layer.insertSublayer(gradient, at: 0)
    }
    
    func addShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
    }

    func removeShadow() {
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowOpacity = 0
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 0
    }
    
    func getSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}

// MARK: Autolayout Helper
extension UIView {
    func setEdgesConstraint(to view: UIView, padding: UIEdgeInsets = .zero) {
        self.setConstraint(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: padding)
    }
    
    func setConstraint(top: NSLayoutYAxisAnchor? = nil, 
                       leading: NSLayoutXAxisAnchor? = nil,
                       bottom: NSLayoutYAxisAnchor? = nil,
                       trailing: NSLayoutXAxisAnchor? = nil,
                       padding: UIEdgeInsets = .zero,
                       size: CGSize = .zero) {
        // enable autolayout for view
        self.translatesAutoresizingMaskIntoConstraints = false
        // -- set layout for view
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        // -- set size for view
        if size.width != 0 {
            self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if size.height != 0 {
            self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    @discardableResult
    func setConstraint(width: CGFloat?, height: CGFloat?, priority: UILayoutPriority = .required) -> (w: NSLayoutConstraint?, h: NSLayoutConstraint?)
    {
        // enable autolayout for view
        self.translatesAutoresizingMaskIntoConstraints = false
        var w: NSLayoutConstraint?
        var h: NSLayoutConstraint?
        
        // -- set size for view
        if let width = width {
            w = self.widthAnchor.constraint(equalToConstant: width)
            w?.priority = priority
            w?.isActive = true
        }
        if let height = height {
            h = self.heightAnchor.constraint(equalToConstant: height)
            h?.priority = priority
            h?.isActive = true
        }
        return (w: w, h: h)
    }
    
    func removeConstraintsToOtherViews() {
        var _spView = superview
        while let spView = _spView{
            for constraint in spView.constraints {
                if (constraint.firstItem as? UIView == self) || (constraint.secondItem  as? UIView == self) {
                    spView.removeConstraint(constraint)
                }
            }
            _spView = spView.superview
        }
    }
    
    func removeSelfConstraints() {
        self.removeConstraintsToOtherViews()
        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func showCenter(callBack: ((Bool) -> Void)?) {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
        let backgroundView = UIView()
        window.addSubview(backgroundView)
        
        if self.superview == nil {
            window.addSubview(self)
            window.bringSubviewToFront(self)
        }
        backgroundView.alpha = 0.0
        self.alpha = 0.0
        self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.3, animations: {
            backgroundView.alpha = 0.6
            self.transform = .identity
            self.alpha = 1
        }, completion: callBack)
    }

}


typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)
enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical
    
    var startPoint: CGPoint {
        return points.startPoint
    }
    
    var endPoint: CGPoint {
        return points.endPoint
    }
    
    var points: GradientPoints {
        switch self {
        case .topRightBottomLeft:
            return (CGPoint(x: 0.0, y: 1.0), CGPoint(x: 1.0, y: 0.0))
        case .topLeftBottomRight:
            return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1, y: 1))
            
        case .horizontal:
            return (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
        case .vertical:
            return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 1.0))
        }
    }
}
