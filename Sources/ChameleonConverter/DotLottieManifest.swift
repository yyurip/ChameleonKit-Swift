//
//  DotLottieManifest.swift
//  ChameleonKit
//
//  Created by Ygor Yuri De Pinho Pessoa on 04.12.24.
//

import Foundation

internal struct DotLottieManifest: Codable {
    
    public var animations: [DotLottieAnimation]
    public var version: String?
    public var author: String?
    public var generator: String?
    
    
    /// Decodes data to Manifest model
    /// - Parameter data: Data to decode
    /// - Throws: Error
    /// - Returns: .lottie Manifest model
    static func decode(from data: Data) throws -> DotLottieManifest {
      try JSONDecoder().decode(DotLottieManifest.self, from: data)
    }

    /// Loads manifest from given URL
    /// - Parameter path: URL path to Manifest
    /// - Returns: Manifest Model
    static func load(from url: URL) throws -> DotLottieManifest {
      let data = try Data(contentsOf: url)
      return try decode(from: data)
    }

    /// Encodes to data
    /// - Parameter encoder: JSONEncoder
    /// - Throws: Error
    /// - Returns: encoded Data
    func encode(with encoder: JSONEncoder = JSONEncoder()) throws -> Data {
      try encoder.encode(self)
    }

    public init(
        animations: [DotLottieAnimation],
        version: String?,
        author: String?,
        generator: String?
    ) {
        self.animations = animations
        self.version = version
        self.author = author
        self.generator = generator
    }
}
