//
//  LottieManifest.swift
//  Chameleon
//
//  Created by Ygor Yuri De Pinho Pessoa on 04.12.24.
//

import Foundation

public struct LottieManifest: Codable {
    
    public var animations: [LottieAnimation]
    public var version: String?
    public var author: String?
    public var generator: String?
    
    
    /// Decodes data to Manifest model
    /// - Parameter data: Data to decode
    /// - Throws: Error
    /// - Returns: .lottie Manifest model
    static func decode(from data: Data) throws -> LottieManifest {
      try JSONDecoder().decode(LottieManifest.self, from: data)
    }

    /// Loads manifest from given URL
    /// - Parameter path: URL path to Manifest
    /// - Returns: Manifest Model
    static func load(from url: URL) throws -> LottieManifest {
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
        animations: [LottieAnimation],
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
