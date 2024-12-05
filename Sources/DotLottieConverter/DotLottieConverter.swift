//
//  DotLottieConverter.swift
//
//
//  Created by Ygor Yuri De Pinho Pessoa on 04.12.24.
//

import Foundation
import Zip

struct DotLottieConverter {
    static func convert(
        files: [URL],
        outputFolder: URL,
        color: String = "#ffffff",
        noLoop: Bool = false
    ) async throws {
        for file in files {

            try await convert(
                file: file,
                output: outputFolder,
                themeColor: color,
                loop: !noLoop
            )
        }
    }
    
    static func convert(
        file: URL,
        output: URL,
        themeColor: String = "#ffffff",
        loop: Bool = true
    ) throws {
        try createAnimationsDirectory()
        try copyLottieFileToAnimationsDirectory(file)
        let filename = file.deletingPathExtension().lastPathComponent
        try createManifest(
            fileName: filename,
            themeColor: themeColor,
            loop: loop
        )
        Zip.addCustomFileExtension(dotLottieExtension)
        try Zip.zipFiles(
            paths: [
                animationsDirectory,
                manifestFileURL
            ],
            zipFilePath: output.appendingPathComponent(filename).appendingPathExtension(dotLottieExtension),
            password: nil,
            compression: .DefaultCompression,
            progress: { progress in
                debugPrint("Compressing file: \(progress)")
            }
        )
    }
}

private extension DotLottieConverter {
    static func createManifest(
        fileName: String,
        themeColor: String = "#ffffff",
        loop: Bool = true
    ) throws {
        let manifest = LottieManifest(
            animations: [
                LottieAnimation(
                    id: fileName,
                    loop: loop,
                    themeColor: themeColor,
                    speed: 1.0
                )
            ],
            version: "1.0",
            author: "LottieFiles",
            generator: "LottieFiles - LottieColorize"
        )
        
        let manifestData = try manifest.encode()
        try manifestData.write(to: manifestFileURL)
    }
    
    static func copyLottieFileToAnimationsDirectory(_ item: URL) throws {
        let destinationURL = animationsDirectory.appendingPathComponent(item.lastPathComponent)
        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.copyItem(at: item, to: destinationURL)
    }
    
    static func createAnimationsDirectory() throws {
        try FileManager.default.createDirectory(
            at: animationsDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }
}

private extension DotLottieConverter {
    static let temporaryDirectory = FileManager.default.temporaryDirectory
    
    static var animationsDirectory: URL {
        temporaryDirectory
            .appendingPathComponent(animationsDirectoryName)
    }
    
    static var manifestFileURL: URL {
        temporaryDirectory
            .appendingPathComponent(manifestFilename)
            .appendingPathExtension(jsonExtension)
    }
    
    static let dotLottieExtension = "lottie"
    static let animationsDirectoryName = "animations"
    static let jsonExtension = "json"
    static let manifestFilename = "manifest"
    
}

private enum DotLottieConverterError: Error {
    case fileNotSupported
}
