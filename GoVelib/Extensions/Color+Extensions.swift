//
//  Color+Extensions.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 16/06/2022.
//

import SwiftUI

// Custom colors.
extension Color {
    static let customBlack = Color.black.opacity(0.7)
    static let ebikeBlue = Color(#colorLiteral(red: 0.3504903913, green: 0.601603508, blue: 0.6459867954, alpha: 1))
    static let mechanicalGreen = Color(#colorLiteral(red: 0.511762023, green: 0.735009253, blue: 0.3372531533, alpha: 1))
    static let parkingBlue = Color(#colorLiteral(red: 0.08886966854, green: 0.1862046123, blue: 0.4970288873, alpha: 1))
}

extension UIColor {
    static let uiCustomBlack = UIColor.black.withAlphaComponent(0.6)
}
