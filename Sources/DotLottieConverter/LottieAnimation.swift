//
//  LottieAnimation.swift
//  Chameleon
//
//  Created by Ygor Yuri De Pinho Pessoa on 04.12.24.
//

import Foundation

public struct LottieAnimation: Codable {
    /// Id of Animation
    public var id: String
    
    /// Loop enabled
    public var loop: Bool?
    
    // appearance color in HEX
    public var themeColor: String?
    
    /// Animation Playback Speed
    public var speed: Float?
    
    /// 1 or -1
    public var direction: Int?
    
    /// mode - "bounce" | "normal"
    public var mode: String?
    
    init(
        id: String,
        loop: Bool? = nil,
        themeColor: String? = nil,
        speed: Float? = nil,
        direction: Int? = nil,
        mode: String? = nil
    ) {
        self.id = id
        self.loop = loop
        self.themeColor = themeColor
        self.speed = speed
        self.direction = direction
        self.mode = mode
    }
}
