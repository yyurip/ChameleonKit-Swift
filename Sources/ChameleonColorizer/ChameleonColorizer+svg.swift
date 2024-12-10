//
//  File.swift
//  
//
//  Created by Ygor Yuri De Pinho Pessoa on 10.12.24.
//

import Foundation

public extension ChameleonColorizer {
    // Colorize from Data
    public static func colorizeSvg(
        input: Data,
        with mapping: [String : String],
        destination: URL,
        generateDotLottieFile: Bool = true
    ) throws -> ColorizeResult {
//        guard let dictionary = try JSONSerialization.jsonObject(
//            with: input
//        ) as? [String:Any]
//        else {
            throw LottieColorizeError.dataConvertion
//        }
//        return try colorizeLottie(
//            input: dictionary,
//            with: mapping,
//            destination: destination,
//            generateDotLottieFile: generateDotLottieFile
//        )
    }
}
