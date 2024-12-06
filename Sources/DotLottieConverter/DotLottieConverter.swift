//
//  DotLottieConverter.swift
//
//
//  Created by Ygor Yuri De Pinho Pessoa on 04.12.24.
//

import Foundation
import Zip

public struct DotLottieConverter {
    // Converts many JSON files into DotLottieFiles
    public static func convert(
        files: [URL],
        outputFolder: URL,
        color: String = "#ffffff",
        loop: Bool = true
    ) throws {
        for file in files {
            try convert(
                file: file,
                output: outputFolder,
                themeColor: color,
                loop: loop
            )
        }
    }
    
    // Converts a JSON file into DotLottieFile
    public static func convert(
        file: URL,
        output: URL,
        themeColor: String = "#ffffff",
        loop: Bool = true
    ) throws {
        // Create needed directories
        try createAnimationsDirectory()
        // Copy json File
        try copyLottieFileToAnimationsDirectory(file)
        // Create manifest file
        let filename = file.deletingPathExtension().lastPathComponent
        try createManifest(
            fileName: filename,
            themeColor: themeColor,
            loop: loop
        )
        // Zipping
        Zip.addCustomFileExtension(dotLottieExtension)
        try Zip.zipFiles(
            paths: [
                animationsDirectory,
                manifestFileURL
            ],
            zipFilePath: zipFilePath(
                destination: output,
                filename: filename
            ),
            password: nil,
            compression: .DefaultCompression,
            progress: {
                progress in
                debugPrint("Compressing file: \(progress)")
            }
        )
        // Removing compress directory
        try FileManager.default.removeItem(at: temporaryCompressDirectory)
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
            generator: "LottieFiles - DotLottieConverter - Lottie Colorize"
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
        try? FileManager.default.createDirectory(
            at: temporaryCompressDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        try? FileManager.default.createDirectory(
            at: animationsDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }
    
    // Return zip path - /filename.lottie
    static func zipFilePath(destination: URL, filename: String) -> URL {
        destination
            .appendingPathComponent(filename)
            .appendingPathExtension(dotLottieExtension)
    }
}

private extension DotLottieConverter {
    static let temporaryCompressDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent(compressDirectoryName)
    
    static var animationsDirectory: URL {
        temporaryCompressDirectory
            .appendingPathComponent(animationsDirectoryName)
    }
    
    static var manifestFileURL: URL {
        temporaryCompressDirectory
            .appendingPathComponent(manifestFilename)
            .appendingPathExtension(jsonExtension)
    }
    
    static let dotLottieExtension = "lottie"
    static let animationsDirectoryName = "animations"
    static let compressDirectoryName = "compress"
    static let jsonExtension = "json"
    static let manifestFilename = "manifest"
    
}
