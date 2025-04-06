import UIKit

/// Utilities for color conversion
class ColorUtilities {
    
    /// Convert a hex string to a UIColor
    /// Format: "#RRGGBB" or "#RRGGBBAA" or "#AARRGGBB" (Android format)
    static func color(fromHexString hexString: String) -> UIColor? {
        // Print debug info for troubleshooting color issues
        print("⚡️ ColorUtilities: Processing color string: \(hexString)")
        
        var hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Special handling for Material colors from Flutter
        // These come in as positive integer values
        if let intValue = Int(hexString), intValue > 0 {
            print("🎨 Converting int color value: \(intValue)")
            // Convert the int to hex - Flutter uses ARGB format
            let hexValue = String(format: "#%08x", intValue)
            hexString = hexValue
        }
        
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        
        // For 3-character hex codes like #RGB
        if hexString.count == 3 {
            let r = String(hexString[hexString.startIndex])
            let g = String(hexString[hexString.index(hexString.startIndex, offsetBy: 1)])
            let b = String(hexString[hexString.index(hexString.startIndex, offsetBy: 2)])
            hexString = r + r + g + g + b + b
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        var alpha: CGFloat = 1.0
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        
        if hexString.count == 8 {
            // Check if it's RRGGBBAA or AARRGGBB format
            let isARGB = (rgbValue & 0xFF000000) > 0
            
            if isARGB {
                // AARRGGBB format (Android/Flutter)
                alpha = CGFloat((rgbValue >> 24) & 0xFF) / 255.0
                red = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
                green = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
                blue = CGFloat(rgbValue & 0xFF) / 255.0
            } else {
                // RRGGBBAA format
                red = CGFloat((rgbValue >> 24) & 0xFF) / 255.0
                green = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
                blue = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
                alpha = CGFloat(rgbValue & 0xFF) / 255.0
            }
        } else if hexString.count == 6 {
            // RRGGBB format
            red = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
            green = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
            blue = CGFloat(rgbValue & 0xFF) / 255.0
            alpha = 1.0
        } else {
            print("⚠️ Invalid color format: \(hexString)")
            return nil
        }
        
        print("🎨 Color components: R=\(red), G=\(green), B=\(blue), A=\(alpha)")
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Convert UIColor to hex string
    static func hexString(from color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
}
