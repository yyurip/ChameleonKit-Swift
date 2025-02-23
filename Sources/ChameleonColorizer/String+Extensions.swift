//
//  String+Extensions.swift
//  Created by Ygor Yuri De Pinho Pessoa on 23.02.25.
//

import Foundation

@available(macOS 13, *)
extension String {
    func numberOfOccurrencesOf(_ string: String) -> Int {
        return self.ranges(of: string).count
    }
}
