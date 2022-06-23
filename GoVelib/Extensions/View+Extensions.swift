//
//  View+Extensions.swift
//  GoVelib
//
//  Created by Raphaël Huang-Dubois on 16/06/2022.
//

import SwiftUI

// To hide a view according to specific condition.
extension View {
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}
