import SwiftUI
import ChameleonConverter

@available(macOS 13, *)
extension ChameleonColorizer {
    // Colorize from Data
    public static func colorizeLottie(
        input: Data,
        with mapping: [String : String],
        destination: URL,
        generateDotLottieFile: Bool = true
    ) throws -> ColorizeResult {
        guard let dictionary = try JSONSerialization.jsonObject(
            with: input
        ) as? [String:Any]
        else {
            throw LottieColorizeError.dataConvertion
        }
        return try colorizeLottie(
            input: dictionary,
            with: mapping,
            destination: destination,
            generateDotLottieFile: generateDotLottieFile
        )
    }
    
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
    
    // Colorize from Dictionary
    public static func colorizeLottie(
        input: [String : Any],
        with mapping: [String : String],
        destination: URL,
        generateDotLottieFile: Bool = true
    ) throws -> ColorizeResult {
        let result = colorize(
            dictionary: input,
            colorMapping: mapping
        )
        let outData = try JSONSerialization.data(
            withJSONObject: result.dictionary,
            options: []
        )
        try outData.write(to: destination)
        
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
        dictionary: [String:Any],
        colorMapping: [String:String],
        numberOfChanges: Int = 0
    ) -> ColorizeMappingResult {
        var dict = dictionary
        var changes = numberOfChanges
        for (key, value) in dict {
            if key == "k" {
                if let numbers = value as? [Double] {
                    if numbers.count == 4 {
                        let color = Color(
                            red: numbers[0],
                            green: numbers[1],
                            blue: numbers[2],
                            opacity: numbers[3]
                        )
                        
                        if let hex = color.toHex(),
                           let newHex = colorMapping[hex] {
                            let newColor = Color(hex: newHex)
                            let rgb = newColor.toRGBA()
                            if !rgb.isEmpty {
                                dict[key] = rgb
                                changes += 1
                            }
                        }
                    }
                }
            }
            
            if var value = value as? [String: Any] {
                let result = colorize(
                    dictionary: value,
                    colorMapping: colorMapping,
                    numberOfChanges: changes
                )
                dict[key] = result.dictionary
                changes = result.changes
            } else if var values = value as? [[String:Any]] {
                dict[key] = values.map {
                    let result = colorize(
                        dictionary: $0,
                        colorMapping: colorMapping,
                        numberOfChanges: changes
                    )
                    changes = result.changes
                    return result.dictionary
                }
            }
        }
        return ColorizeMappingResult(
            dictionary: dict,
            changes: changes
        )
    }
}

public struct ColorizeResult {
    public var changes: Int
    public var outputURL: URL
}

private struct ColorizeMappingResult {
    var dictionary: [String:Any]
    var changes: Int
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
    
    func toRGBA(alpha: Bool = false) -> [Float] {
        guard let components = cgColor?.components, components.count >= 3 else {
            return []
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(components[3])
        
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
