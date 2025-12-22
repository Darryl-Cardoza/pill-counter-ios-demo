//
//  PillCountingButton.swift
//  PillCounter
//
//  Created by HC on 04/11/25.
//

import SwiftUI

struct PillCountingButton: View {
    // MARK: - Properties

    let iconName: String?
    let title: String
    let action: () -> Void
    let textColor: Color
    let backgroundColor: Color
    let borderColor: Color

    let frameWidth: CGFloat?

    // icon color
    let iconColor: Color?

    // Customizable appearance parameters
    var font: Font
    var cornerRadius: CGFloat
    var horizontalPadding: CGFloat
    var verticalPadding: CGFloat
    var iconSize: CGFloat

    // MARK: - Init

    init(
        iconName: String? = nil,
        title: String,
        textColor: Color = .white,
        backgroundColor: Color = .blue,
        borderColor: Color = .clear,
        font: Font = .system(size: 16, weight: .medium),
        cornerRadius: CGFloat = 32,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 14,
        iconSize: CGFloat = 20,
        action: @escaping () -> Void,
        frameWidth: CGFloat? = nil,
        iconColor: Color? = nil
    ) {
        self.iconName = iconName
        self.title = title
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.font = font
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.iconSize = iconSize
        self.action = action
        self.frameWidth = frameWidth
        self.iconColor = iconColor
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let iconName = iconName, !iconName.isEmpty {
                    if let iconColor = iconColor {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconSize, height: iconSize)
                            .overlay(
                                iconColor
                                    .mask(
                                        Image(iconName)
                                            .resizable()
                                            .scaledToFit()
                                    )
                            )
                    } else {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconSize, height: iconSize)
                    }
                }

                Text(title)
                    .font(font)
                    .foregroundColor(textColor)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(width: frameWidth ?? nil)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .cornerRadius(cornerRadius)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        // Default
        PillCountingButton(
            iconName: "fixed_count",
            title: "Count Pills",
            action: { print("Count tapped") }
        )

        // Custom look
        PillCountingButton(
            iconName: nil,
            title: "Add Entry",
            textColor: .blue,
            backgroundColor: .gray.opacity(0.2),
            borderColor: Color.red,
            font: .system(size: 12, weight: .semibold),
            cornerRadius: 32,
            horizontalPadding: 16,
            verticalPadding: 12,
            iconSize: 24,
            action: { print("Add tapped") }
        )
    }
    .padding()
}
