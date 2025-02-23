import SwiftUI
import ChameleonConverter

@available(macOS 13, *)
extension ChameleonColorizer {
    // Colorize from URL
    public static func colorizeLottie(
        input: URL,
        with mapping: [String : String],
        destination: URL,
        generateDotLottieFile: Bool = true
    ) throws -> ColorizeResult {
        let data = try Data(contentsOf: input)
        return try colorizeLottie(
            input: data,
            with: mapping,
            destination: destination,
            generateDotLottieFile: generateDotLottieFile
        )
    }
    
    // Colorize from Data
    public static func colorizeLottie(
        input: Data,
        with mapping: [String : String],
        destination: URL,
        generateDotLottieFile: Bool = true
    ) throws -> ColorizeResult {
        guard let jsonString = String(data: input, encoding: .utf8)
        else {
            throw LottieColorizeError.dataConvertion
        }
        
        return try colorizeLottie(
            jsonString: jsonString,
            with: mapping,
            destination: destination,
            generateDotLottieFile: generateDotLottieFile
        )
    }
    
    // Colorize from Dictionary
    public static func colorizeLottie(
        jsonString: String,
        with mapping: [String : String],
        destination: URL,
        generateDotLottieFile: Bool = true
    ) throws -> ColorizeResult {
        let result = try colorize(
            jsonString: jsonString,
            colorMapping: mapping
        )
        let outputData = Data(result.jsonString.utf8)
        try outputData.write(to: destination)
        
        if generateDotLottieFile {
            try ChameleonConverter.convertJsonToDotLottie(
                file: destination,
                output: destination.deletingLastPathComponent()
            )
        }
        
        return ColorizeResult(
            changes: result.changes,
            outputURL: destination
        )
    }
}

@available(macOS 13, *)
private extension ChameleonColorizer {
    static func colorize(
        jsonString: String,
        colorMapping: [String:String]
    ) throws -> ColorizeMappingResult {
        
        guard let dictionary = try JSONSerialization.jsonObject(
            with: Data(jsonString.utf8)
        ) as? [String:Any]
        else {
            throw LottieColorizeError.dataConvertion
        }
        
        let replaceableColors = identifyReplaceableColors(
            dictionary,
            colorMapping: colorMapping
        )
        
        var newJsonString = jsonString
        var numberOfChanges = 0
        for (key, value) in replaceableColors {
            numberOfChanges += newJsonString.numberOfOccurrencesOf(key)
            newJsonString = newJsonString.replacingOccurrences(of: key, with: value)
        }

        return ColorizeMappingResult(
            jsonString: newJsonString,
            changes: numberOfChanges
        )
    }
    
    static func identifyReplaceableColors(
        _ object: [String: Any],
        colorMapping: [String: String]
    ) -> [String: String] {
        var changes: [String: String] = [:]

        for (key, value) in object {
            if key == "k",
               let colorDoubleArray = doubleArray(value),
               let oldColor = colorDoubleArray.toColor,
               let hex = oldColor.toHex(),
               let newHex = colorMapping[hex] {

                let newColor = Color(hex: newHex)
                if oldColor != newColor {
                    let oldObjString = colorDoubleArray.toKColorObjectString
                    let newObjString = newColor.toRGBADoubleArray().toKColorObjectString
                    changes[oldObjString] = newObjString
                }
            } else if let nestedDict = value as? [String: Any] {
                let nestedChanges = identifyReplaceableColors(nestedDict, colorMapping: colorMapping)
                changes.merge(nestedChanges) { _, new in new }
            } else if let nestedArray = value as? [[String: Any]] {
                for nestedObject in nestedArray {
                    let nestedChanges = identifyReplaceableColors(nestedObject, colorMapping: colorMapping)
                    changes.merge(nestedChanges) { _, new in new }
                }
            }
        }

        return changes
    }
            
    static func doubleArray(_ value: Any) -> [Double]? {
        if let array = value as? [Double],
            array.count == 4 {
                return array
        }
        return nil
    }
}

public struct ColorizeResult {
    public var changes: Int
    public var outputURL: URL
}

private struct ColorizeMappingResult {
    var jsonString: String
    var changes: Int
}

@available(macOS 11, *)
extension Array where Element == Double {
    var toKColorObjectString: String {
        let colorsString = self.map(\.formatDouble).joined(separator: ",")
        return "\"k\":[\(colorsString)]"
    }
    
    var toColor: Color? {
        if self.count == 4 {
            return Color(
                red: self[0],
                green: self[1],
                blue: self[2],
                opacity: self[3]
            )
        }
        return nil
    }
}

@available(macOS 11, *)
extension Color {
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor?.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
    func toRGBADoubleArray(alpha: Bool = false) -> [Double] {
        guard let components = cgColor?.components, components.count >= 3 else {
            return []
        }
        
        let r = Double(components[0])
        let g = Double(components[1])
        let b = Double(components[2])
        var a = Double(components[3])
        
        return [r, g, b, a]
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

enum LottieColorizeError: Error {
    case outputCreation
    case dataConvertion
}

extension Double {
    var formatDouble: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16
        formatter.decimalSeparator = "."
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
extension String {
    func cleanDecimalZeros() -> String {
        let pattern = #"(?<=[,[])(\d+)\.0(?=[,\]])"#
        return self.replacingOccurrences(of: pattern, with: "$1", options: .regularExpression)
    }
}
