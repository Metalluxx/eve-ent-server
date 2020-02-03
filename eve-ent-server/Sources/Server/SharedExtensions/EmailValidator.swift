//
//  File.swift
//  
//
//  Created by Metalluxx on 17.12.2019.
//

import Foundation

public extension String {
    var isEmail: Bool {
        return self.range(of: "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}", options: .regularExpression) != nil
    }
}
