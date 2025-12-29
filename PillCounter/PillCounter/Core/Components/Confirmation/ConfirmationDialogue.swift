//
//  ConfirmationDialogue.swift
//  PillCounter
//
//  Created by HC on 13/11/25.
//

import SwiftUI

struct ConfirmationDialogue: View {

    @EnvironmentObject private var appColors: AppColors

    let title: String
    let message: String
    let cancelButtonText: String
    let confirmButtonText: String
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 15) {

            Text(title)
                .font(.headline)
                .foregroundStyle(appColors.text)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(appColors.text)

            HStack(spacing: 16) {

                PillCountingButton(
                    iconName: nil,
                    title: cancelButtonText.uppercased(),
                    textColor: appColors.text,
                    backgroundColor: appColors.primaryBackground,
                    borderColor: appColors.primary,
                    font: .system(size: 12, weight: .semibold),
                    cornerRadius: 30,
                    horizontalPadding: 32,
                    verticalPadding: 14,
                    iconSize: 0,
                    action: onCancel
                )

                PillCountingButton(
                    iconName: nil,
                    title: confirmButtonText.uppercased(),
                    textColor: appColors.text,
                    backgroundColor: appColors.primary,
                    borderColor: .clear,
                    font: .system(size: 12, weight: .regular),
                    cornerRadius: 30,
                    horizontalPadding: 32,
                    verticalPadding: 14,
                    iconSize: 0,
                    action: onConfirm
                )
            }
        }
        .frame(width: 275)
        .padding()
        .background(appColors.primaryBackground)
        .cornerRadius(24)
    }
}


//#Preview {
//    let appColors = AppColors.shared
//
//    ZStack {
//        Color.black.opacity(0.4)
//            .ignoresSafeArea()
//
//        ConfirmationDialogue(
//            title: "Confirmation",
//            message: "Are you sure you want to go back?",
//            onCancel: {
//                print("Preview: Cancel tapped")
//            },
//            onConfirm: {
//                print("Preview: OK tapped")
//            }
//        )
//        .environmentObject(appColors)
//        .padding()
//    }
//    .preferredColorScheme(.dark)
//}

