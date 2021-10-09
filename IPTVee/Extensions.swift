//
//  Extensions.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/3/21.
//

import Foundation
import SwiftUI

extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}

public extension String {
    var base64Decoded: String? {
         String(data: Data(base64Encoded: self) ?? Data(), encoding: .utf8)
    }
}

public extension String {
    func removingLeadingSpaces() -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return self
        }
        return String(self[index...])
    }
}

public extension String {

    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss")-> Date?{

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date

    }
}

//"MMM dd yyyy h:mm a"
public extension Date {
    func toString(withFormat format: String = "h:mm a") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: self)
        return str
    }
}

extension UIImage {
    func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        guard let ctx = UIGraphicsGetCurrentContext() else { return self }
        
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        
        if let cgImage = cgImage {
            ctx.setFillColor(color.cgColor)
            ctx.fill(rect)
            ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
            ctx.draw(cgImage, in: rect)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
    
    func maskWithColor(color: UIColor) -> UIImage? {
        guard let maskImage = cgImage else { return self }
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        if let context = CGContext(data: nil, width: Int(width), height: Int(height),
                                   bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace,
                                   bitmapInfo: bitmapInfo.rawValue),
            let cgImage = context.makeImage() {
            context.clip(to: bounds, mask: maskImage)
            context.setFillColor(color.cgColor)
            context.fill(bounds)
            
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return self
        }
    }
}
