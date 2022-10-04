//
//  ExtentionC.swift
//  H2Care
//
//  Created by lee wonyoung on 2019/10/30.
//  Copyright © 2019 Lee.210. All rights reserved.
//

import Foundation
import Kingfisher

extension UIImage{
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func imageByCombiningImage(firstImage: UIImage, withImage secondImage: UIImage, seconpoX : Int, seconpoY : Int) -> UIImage {
        
        let newImageWidth  = max(firstImage.size.width,  secondImage.size.width )
        let newImageHeight = max(firstImage.size.height, secondImage.size.height)
        let newImageSize = CGSize(width : newImageWidth, height: newImageHeight)
        
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
        
        let firstImageDrawX  = round((newImageSize.width  - firstImage.size.width  ) / 2)
        let firstImageDrawY  = round((newImageSize.height - firstImage.size.height ) / 2)
        
        let secondImageDrawX = round((newImageSize.width  - secondImage.size.width ) / 2)
        let secondImageDrawY = round((newImageSize.height - secondImage.size.height) / 2)
        
        firstImage .draw(at: CGPoint(x: firstImageDrawX,  y: firstImageDrawY))
        secondImage.draw(at: CGPoint(x: (secondImageDrawX + CGFloat(seconpoX)), y: secondImageDrawY + CGFloat(seconpoY)))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        
        return image!
    }
    public class func gif(data: Data) -> UIImage? {
            // Create source from data
            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                print("SwiftGif: Source for the image does not exist")
                return nil
            }

            return UIImage.animatedImageWithSource(source)
        }

        public class func gif(url: String) -> UIImage? {
            // Validate URL
            guard let bundleURL = URL(string: url) else {
                print("SwiftGif: This image named \"\(url)\" does not exist")
                return nil
            }

            // Validate data
            guard let imageData = try? Data(contentsOf: bundleURL) else {
                print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
                return nil
            }

            return gif(data: imageData)
        }

        public class func gif(name: String) -> UIImage? {
            // Check for existance of gif
            guard let bundleURL = Bundle.main
              .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
            }

            // Validate data
            guard let imageData = try? Data(contentsOf: bundleURL) else {
                print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
                return nil
            }

            return gif(data: imageData)
        }

        @available(iOS 9.0, *)
        public class func gif(asset: String) -> UIImage? {
            // Create source from assets catalog
            guard let dataAsset = NSDataAsset(name: asset) else {
                print("SwiftGif: Cannot turn image named \"\(asset)\" into NSDataAsset")
                return nil
            }

            return gif(data: dataAsset.data)
        }

        internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
            var delay = 0.1

            // Get dictionaries
            let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
            let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
            defer {
                gifPropertiesPointer.deallocate()
            }
            let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
            if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
                return delay
            }

            let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

            // Get delay time
            var delayObject: AnyObject = unsafeBitCast(
                CFDictionaryGetValue(gifProperties,
                    Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
                to: AnyObject.self)
            if delayObject.doubleValue == 0 {
                delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                    Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
            }

            if let delayObject = delayObject as? Double, delayObject > 0 {
                delay = delayObject
            } else {
                delay = 0.1 // Make sure they're not too fast
            }

            return delay
        }

        internal class func gcdForPair(_ lhs: Int?, _ rhs: Int?) -> Int {
            var lhs = lhs
            var rhs = rhs
            // Check if one of them is nil
            if rhs == nil || lhs == nil {
                if rhs != nil {
                    return rhs!
                } else if lhs != nil {
                    return lhs!
                } else {
                    return 0
                }
            }

            // Swap for modulo
            if lhs! < rhs! {
                let ctp = lhs
                lhs = rhs
                rhs = ctp
            }

            // Get greatest common divisor
            var rest: Int
            while true {
                rest = lhs! % rhs!

                if rest == 0 {
                    return rhs! // Found it
                } else {
                    lhs = rhs
                    rhs = rest
                }
            }
        }

        internal class func gcdForArray(_ array: [Int]) -> Int {
            if array.isEmpty {
                return 1
            }

            var gcd = array[0]

            for val in array {
                gcd = UIImage.gcdForPair(val, gcd)
            }

            return gcd
        }

        internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
            let count = CGImageSourceGetCount(source)
            var images = [CGImage]()
            var delays = [Int]()

            // Fill arrays
            for index in 0..<count {
                // Add image
                if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                    images.append(image)
                }

                // At it's delay in cs
                let delaySeconds = UIImage.delayForImageAtIndex(Int(index),
                    source: source)
                delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
            }

            // Calculate full duration
            let duration: Int = {
                var sum = 0

                for val: Int in delays {
                    sum += val
                }

                return sum
                }()

            // Get frames
            let gcd = gcdForArray(delays)
            var frames = [UIImage]()

            var frame: UIImage
            var frameCount: Int
            for index in 0..<count {
                frame = UIImage(cgImage: images[Int(index)])
                frameCount = Int(delays[Int(index)] / gcd)

                for _ in 0..<frameCount {
                    frames.append(frame)
                }
            }

            // Heyhey
            let animation = UIImage.animatedImage(with: frames,
                duration: Double(duration) / 1000.0)

            return animation
        }
}

extension Date {
    
    /// Returns the amount of years from another date
    func years(from date: Date, now : Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: now).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date, now : Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: now).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date, now : Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: now).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date, now : Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: now).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date, now : Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: now).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date, now : Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: now).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date, now : Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: now).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date, now : Date) -> String {
        if years(from: date, now: now)   > 0 { return "\(years(from: date, now: now))년 전"   }
        if months(from: date, now: now)  > 0 { return "\(months(from: date, now: now))개월 전"  }
        if weeks(from: date, now: now)   > 0 { return "\(weeks(from: date, now: now))주 전"   }
        if days(from: date, now: now)    > 0 { return "\(days(from: date, now: now))일 전"    }
        if hours(from: date, now: now)   > 0 { return "\(hours(from: date, now: now))시간 전"   }
        if minutes(from: date, now: now) > 0 { return "\(minutes(from: date, now: now))분 전" }
        if seconds(from: date, now: now) > 0 { return "\(seconds(from: date, now: now))초 전" }
        return "now"
    }
    
}
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    func hexStringToUIColor () -> UIColor {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    // 이메일 정규식
    func validateEmail() -> Bool {
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: self)
    }
    // 패스워드는 최소8자이상, 대문자, 소문자, 숫자 조합인지 검증하게되어있습니다
    func validatePassword() -> Bool {
        //let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}$"
        let passwordRegEx = "^(?=.*[0-9])(?=.*[a-z]).{8,}$"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return predicate.evaluate(with: self)
    }
    
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    func DecimalWon() -> String{
        if !self.isNumber {
            return "0";
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: Int(self) ?? 0)) ?? "0"
        
        return result
    }
    
    //heightT,widthT 레이블에 텍스트를 넣을때 예상 레이블 높이를 구해주기
    func heightT(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func widthT(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    func PhoneFormat(with mask: String) -> String {
        let numbers = self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)

            } else {
                result.append(ch)
            }
        }
        return result
    }
    var localized: String {
        
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    func localized(txt : String) -> String {
        
        return String(format: NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: ""), txt)
    }
    func nsrange(of value : String) -> NSRange {
        let nsString : NSString = NSString(string: self)
        return nsString.range(of: value)
    }
    // 한글 숫자 영문 특수문자 포함 정규식 (이모티콘 제외)
    func hasCharactersNew() -> Bool {
        do {
            //let regex = try NSRegularExpression(pattern: "^[0-9a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ`~!@#$%^&*()\\-_=+\\[{\\]}\\\\|;:'\",<.>/?\\s]$", options: .caseInsensitive)
            let regex = try NSRegularExpression(pattern: "^[a-zA-Zㄱ-ㅎ가-힣0-9ㅏ-ㅣ ]+$", options: .caseInsensitive)
            if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count))
            {
                return true
            }
            
        }catch {
            return false
        }
        return false
    }
}
extension CALayer {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.mask = mask
        }
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat, widthp : CGFloat = 200) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width + widthp, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width + widthp, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
    func addSperater(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat, heipl : CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: (heipl/2 * -1), width: width, height: (frame.height  + heipl))
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: (heipl/2 * -1), width: width, height: (frame.height  + heipl))
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
    func roundedLaout(corneridx : Int, points : UIRectCorner){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: points,
                                     cornerRadii: CGSize(width: corneridx, height: corneridx))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        self.mask = maskLayer1
    }
    
}


extension UIImageView {
    
    func setImage(with urlString: String) {
        let cache = ImageCache.default
        cache.retrieveImage(forKey: urlString, options: nil) { (image, _) in // 캐시에서 키를 통해 이미지를 가져온다.
            if let image = image { // 만약 캐시에 이미지가 존재한다면
                self.image = image // 바로 이미지를 셋한다.
            } else {
                let url = URL(string: urlString) // 캐시가 없다면
                let resource = ImageResource(downloadURL: url!, cacheKey: urlString) // URL로부터 이미지를 다운받고 String 타입의 URL을 캐시키로 지정하고
                self.kf.setImage(with: resource) // 이미지를 셋한다.
            }
        }
    }
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    public func loadGif(name: String) {
            DispatchQueue.global().async {
                let image = UIImage.gif(name: name)
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }

        @available(iOS 9.0, *)
        public func loadGif(asset: String) {
            DispatchQueue.global().async {
                let image = UIImage.gif(asset: asset)
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    var contentClippingRect: CGRect {
        //이미지뷰 안에 실제 이미지가 핏에 맞게 되었을때 실제 크기
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
extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

extension UIView {
    var parentViewController: UIViewController? {
            var parentResponder: UIResponder? = self
            while parentResponder != nil {
                parentResponder = parentResponder?.next
                if let viewController = parentResponder as? UIViewController {
                    return viewController
                }
            }
            return nil
        }
    /**
     Set a shadow on a UIView.
     - parameters:
        - color: Shadow color, defaults to black
        - opacity: Shadow opacity, defaults to 1.0
        - offset: Shadow offset, defaults to zero
        - radius: Shadow radius, defaults to 0
        - viewCornerRadius: If the UIView has a corner radius this must be set to match
    */
    func setShadowWithColor(color: UIColor?, opacity: Float?, offset: CGSize?, radius: CGFloat, viewCornerRadius: CGRect?) {
        //layer.shadowPath = UIBezierPath(rect: viewCornerRadius!).cgPath;
        layer.shadowPath = UIBezierPath(rect: CGRect.init(x: layer.bounds.minX, y: layer.bounds.minY, width: layer.bounds.width + 200, height: layer.bounds.height)).cgPath;
        
        layer.shadowColor = color?.cgColor ?? UIColor.black.cgColor
        layer.shadowOpacity = opacity ?? 1.0
        layer.shadowOffset = offset ?? CGSize.zero
        layer.shadowRadius = radius ?? 0.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
    }
    
    func setLv(reportcnt : Int) -> Int{
        var fm_nLv : Int = (reportcnt / 10);
        fm_nLv += 1
        self.layer.cornerRadius = 5
        if fm_nLv >= 11 && fm_nLv <= 20{
            self.layer.backgroundColor = UIColor(rgb: 0xeaeaea).cgColor
        }else if fm_nLv >= 21 && fm_nLv <= 30{
            self.layer.backgroundColor = UIColor(rgb: 0xeaeaea).cgColor
        }else if fm_nLv >= 31 && fm_nLv <= 40{
            self.layer.backgroundColor = UIColor(rgb: 0xeaeaea).cgColor
        }else if fm_nLv >= 41 && fm_nLv <= 50{
            self.layer.backgroundColor = UIColor(rgb: 0xeaeaea).cgColor
        }else{
            self.layer.backgroundColor = UIColor(rgb: 0xeaeaea).cgColor
        }
        return fm_nLv;
    }
    func getLvImgIcon(lv : Int) -> String{
        var fm_sImg : String = "level_01";
        if lv >= 11 && lv <= 20 {
            fm_sImg = "level_02";
        }else if lv >= 21 && lv <= 30 {
            fm_sImg = "level_03";
        } else if lv >= 31 && lv <= 40 {
            fm_sImg = "level_04";
        }else if lv >= 41{
            fm_sImg = "level_05";
        }
        return fm_sImg;
    }
    func colorOfPoint(point: CGPoint) -> UIColor {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        var pixelData: [UInt8] = [0, 0, 0, 0]
        
        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        
        self.layer.render(in: context!)
        
        let red: CGFloat = CGFloat(pixelData[0]) / CGFloat(255.0)
        let green: CGFloat = CGFloat(pixelData[1]) / CGFloat(255.0)
        let blue: CGFloat = CGFloat(pixelData[2]) / CGFloat(255.0)
        let alpha: CGFloat = CGFloat(pixelData[3]) / CGFloat(255.0)
        
        let color: UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
        return color
    }
}
extension UIColor {
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }

    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)

            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}
extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
    func TextPartColor(partstr : String, Color : UIColor){
        let attributedStr = NSMutableAttributedString(string: self.text!)

        // text의 range 중에서 partstr 라는 글자는 UIColor로 변경
        attributedStr.addAttribute(.foregroundColor, value: Color, range: (self.text! as NSString).range(of: partstr))

        // 설정이 적용된 text를 label의 attributedText에 저장
        self.attributedText = attributedStr
    }
    func TextPartBold(partstr : String, fontSize : CGFloat){
        
        let attributedStr = NSMutableAttributedString(string: self.text!)
        
        attributedStr.addAttribute(.font, value: UIFont.systemFont(ofSize: fontSize, weight: .medium), range: (self.text! as NSString).range(of: partstr))
        
        self.attributedText = attributedStr
    }
    func TextCancelLine(partstr : String){
        let attributeString = NSMutableAttributedString(string: self.text!)
        let range = self.text!.nsrange(of: partstr)
        attributeString.addAttribute(.strikethroughStyle, value:1,  range: range)
        self.attributedText = attributeString
    }
    
}

extension Dictionary {
    func merge(dict: Dictionary<Key,Value>) -> Dictionary<Key,Value> {
        var mutableCopy = self
        for (key, value) in dict {
            // If both dictionaries have a value for same key, the value of the other dictionary is used.
            mutableCopy[key] = value
        }
        return mutableCopy
    }
}
/*
extension UIDevice {
    
    // 노치판단
    var hasNotch: Bool
    {
        let bottom = UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
        print(bottom);
        return bottom > 0
    }
}
*/
 extension UIDevice {
     var hasNotch: Bool {
         let bottom = UIWindow.key?.safeAreaInsets.bottom ?? 0
         return bottom > 0
     }
 }
extension UITextView{
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
            let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
            let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

            let toolbar: UIToolbar = UIToolbar()
            toolbar.barStyle = .default
            toolbar.items = [
                UIBarButtonItem(title: "취소", style: .plain, target: onCancel.target, action: onCancel.action),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "확인", style: .done, target: onDone.target, action: onDone.action)
            ]
            toolbar.sizeToFit()

            self.inputAccessoryView = toolbar
        }
    func addDoneToolbar(onDone: (target: Any, action: Selector)? = nil) {
            let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

            let toolbar: UIToolbar = UIToolbar()
            toolbar.barStyle = .default
            toolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "확인", style: .done, target: onDone.target, action: onDone.action)
            ]
            toolbar.sizeToFit()

            self.inputAccessoryView = toolbar
        }

        // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}
extension UITextField {
    func addLeftPadding(whp : CGFloat = 10) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: whp, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
            let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
            let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

            let toolbar: UIToolbar = UIToolbar()
            toolbar.barStyle = .default
            toolbar.items = [
                UIBarButtonItem(title: "취소", style: .plain, target: onCancel.target, action: onCancel.action),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "확인", style: .done, target: onDone.target, action: onDone.action)
            ]
            toolbar.sizeToFit()

            self.inputAccessoryView = toolbar
        }
    func addDoneToolbar(onDone: (target: Any, action: Selector)? = nil) {
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "확인", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    func addCancelToolbar(onDone: (target: Any, action: Selector)? = nil) {
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "닫기", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    

        // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

extension UIViewController {
    @objc func topMostViewController() -> UIViewController {
        // Handling Modal views
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        // Handling UIViewController's added as subviews to some other views.
        else {
            for view in self.view.subviews
            {
                // Key property which most of us are unaware of / rarely use.
                if let subViewController = view.next {
                    if subViewController is UIViewController {
                        let viewController = subViewController as! UIViewController
                        return viewController.topMostViewController()
                    }
                }
            }
            return self
        }
    }
}

extension UITabBarController {
    override func topMostViewController() -> UIViewController {
        return self.selectedViewController!.topMostViewController()
    }
}

extension UINavigationController {
    override func topMostViewController() -> UIViewController {
        return self.visibleViewController!.topMostViewController()
    }
}

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
