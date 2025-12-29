//
//  SecurityViolationView.swift
//  PillCounter
//
//  Created by HC on 29/12/25.
//

import SwiftUI

struct SecurityViolationView: View {
    
    @EnvironmentObject private var appColors: AppColors

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 48))
                .foregroundColor(.red)

            Text("Security Alert")
                .font(.title2)
                .bold()

            Text(
                """
                This device does not meet security requirements.
                To protect your data, the app cannot continue.
                """
            )
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)

            PillCountingButton(
                iconName: nil,
                title: "Exit",
                textColor: appColors.text,
                backgroundColor: appColors.secondary,
                borderColor: .clear,
                font: .system(size: 14, weight: .semibold),
                cornerRadius: 30,
                horizontalPadding: 32,
                verticalPadding: 14,
                iconSize: 0,
                action: {
                    exit(0)
                }
            )
            .padding(.top, 20)
        }
        .padding()
    }
}

#Preview {
    SecurityViolationView()
}
