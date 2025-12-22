//
//  View+.swift
//  PillCounter
//
//  Created by HC on 17/11/25.
//

import SwiftUI

extension View {
    func customPopup<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            CustomPopup(isPresented: isPresented, popupContent: content))
    }
}
