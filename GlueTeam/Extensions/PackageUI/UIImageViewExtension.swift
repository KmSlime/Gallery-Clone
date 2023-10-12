//
//  UIImageViewExtension.swift
//  GlueTeam
//
//  Created by LIEMNH on 11/10/2023.
//

import UIKit
import Photos

extension UIImageView {
    @objc func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                    let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}

extension UIImage {
    func crop() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        var transform: CGAffineTransform = .identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2))
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            // CORRECTION: Need to assign to transform here
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            // CORRECTION: Need to assign to transform here
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        var ctx: CGContext? = nil
        if let CGImage = self.cgImage?.colorSpace {
            ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage?.bitsPerComponent ?? 0, bytesPerRow: 0, space: CGImage, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        }
        guard let ctxStrong = ctx, let cgImage = self.cgImage else {return self}
        ctxStrong.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            
            ctxStrong.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height , height: self.size.width))
            
        default:
            ctxStrong.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width , height: self.size.height))
        }
        
        if let cgImage = ctxStrong.makeImage() {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
    
    func resizedImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image(actions: { rendererContext in
            self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        })
    }
    
}

extension UIImage {
    convenience init?(color: UIColor) {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 10, height: 2), false, 0)
        let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        color.setFill()
        bezierPath.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        guard  let cgImage = image.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
    static func withColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image =  UIGraphicsImageRenderer(size: size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
        return image
    }
}

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.pngData() else {return nil}
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}

extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }
        
        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }
        
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}

extension UIImage {
    class func outlinedEllipse(size: CGSize, color: UIColor, lineWidth: CGFloat = 1.0) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        // Inset the rect to account for the fact that strokes are
        // centred on the bounds of the shape.
        let rect = CGRect(origin: .zero, size: size).insetBy(dx: lineWidth * 0.5, dy: lineWidth * 0.5)
        context.addEllipse(in: rect)
        context.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

@objc enum ImageRatioStandard: Int {
    case ratio_1_1, ratio_3_2, ratio_4_3, ratio_16_9, ratio_16_10
    case unknown
    
    //MARK: - FOR LIST ITEM
    func getMediumSize() -> CGSize {
        switch self {
        case .ratio_1_1:
            return CGSize(width: 240, height: 240)
        case .ratio_3_2:
            return CGSize(width: 240, height: 160)
        case .ratio_4_3:
            return CGSize(width: 240, height: 180)
        case .ratio_16_9:
            return CGSize(width: 240, height: 135)
        case .ratio_16_10:
            return CGSize(width: 240, height: 150)
        case .unknown:
            return CGSize(width: 0, height: 0)
        }
    }
    
    //MARK: - FOR DETAIL ITEM
    func getLargeSize() -> CGSize {
        switch self {
        case .ratio_1_1:
            return CGSize(width: 480, height: 480)
        case .ratio_3_2:
            return CGSize(width: 480, height: 320)
        case .ratio_4_3:
            return CGSize(width: 480, height: 360)
        case .ratio_16_9:
            return CGSize(width: 480, height: 270)
        case .ratio_16_10:
            return CGSize(width: 480, height: 300)
        case .unknown:
            return CGSize(width: 0, height: 0)
        }
    }
}

extension UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
