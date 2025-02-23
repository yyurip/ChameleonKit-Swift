//
//  ChameleonColorizer+Svg.swift
//
//  Created by Ygor Yuri De Pinho Pessoa on 10.12.24.
//

import Foundation

@available(macOS 13, *)
public extension ChameleonColorizer {
    // Colorize from URL
    public static func colorizeSvg(
        input: URL,
        with mapping: [String : String],
        destination: URL
    ) throws -> ColorizeResult {
        guard let data = try? Data(contentsOf: input)
        else {
            throw LottieColorizeError.dataConvertion
        }
        return try colorizeSvg(
            input: data,
            with: mapping,
            destination: destination
        )
    }
    
    // Colorize from Data
    public static func colorizeSvg(
        input: Data,
        with mapping: [String : String],
        destination: URL
    ) throws -> ColorizeResult {
        guard let svgString = String(data: input, encoding: .utf8)
        else {
            throw LottieColorizeError.dataConvertion
        }
        return try colorizeSvg(
            input: svgString,
            with: mapping,
            destination: destination
        )
    }
    
    // Colorize from String
    public static func colorizeSvg(
        input: String,
        with mapping: [String : String],
        destination: URL
    ) throws -> ColorizeResult {
        let result = try colorizeSvg(
            input: input,
            colorMapping: mapping
        )
        let outData = try Data(result.svg.utf8)
        try outData.write(to: destination)
        
        return ColorizeResult(
            changes: result.changes,
            outputURL: destination
        )
    }
}

@available(macOS 13, *)
private extension ChameleonColorizer {
    static func colorizeSvg(
        input: String,
        colorMapping: [String:String]
    ) -> ColorizeSvgMappingResult {
        var numberOfChanges: Int = 0
        var editedSvg = input
        
        for (key, value) in colorMapping {
            numberOfChanges += editedSvg.numberOfOccurrencesOf(key)
            editedSvg = editedSvg.replacingOccurrences(of: key, with: value)
        }
        return ColorizeSvgMappingResult(
            svg: editedSvg,
            changes: numberOfChanges
        )
    }
}

private struct ColorizeSvgMappingResult {
    let svg: String
    let changes: Int
}

