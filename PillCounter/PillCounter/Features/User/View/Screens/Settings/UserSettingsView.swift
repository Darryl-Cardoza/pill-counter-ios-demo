//
//  UserSettingsView.swift
//  PillCounter
//
//  Created by HC on 06/11/25.
//

import SwiftUI

struct UserSettingsView: View {

    @State private var isOn: Bool = AppStorageManager.shared
        .isPillCountingEnabled

    // 1. Source of Truth (The actual saved setting)
    @State private var selectedSaveHistoryOption: SaveHistoryOption =
        AppStorageManager.shared.saveHistoryOption

    // 2. Temporary State (The option the user *wants* to switch to)
    @State private var pendingOption: SaveHistoryOption? = nil

    // 3. UI State for Popup
    @State private var showConfirmationPopup: Bool = false

    @EnvironmentObject private var appColors: AppColors

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BaseView(
                    topRatio: 1.0,
                    topContent: {
                        userSettingsContent(geometry: geometry)
                    },
                    bottomContent: {
                        EmptyView()
                    },
                    headerActions: { EmptyView() },
                    showBackButton: true,
                    showHamburgerMenu: false,
                    title: NSLocalizedString("SETTINGS", comment: "")
                )
            }
        }
        .customPopup(isPresented: $showConfirmationPopup) {
            confirmationPopUp
        }
    }
    
    private var confirmationPopUp: some View {
        ConfirmationDialogue(
            title: "Are you sure want to keep history for \(pendingOption?.displayText ?? selectedSaveHistoryOption.displayText)",
            message:
                "Note: Data older than this period will be permanently deleted.",
            cancelButtonText: "NO",
            confirmButtonText: "YES"
        ) {
            // Cancel Action: Reset pending and hide popup
            pendingOption = nil
            showConfirmationPopup = false
        } onConfirm: {
            // Confirm Action: Commit the change
            if let newOption = pendingOption {
                selectedSaveHistoryOption = newOption
                AppStorageManager.shared.saveHistoryOption =
                    newOption
            }
            showConfirmationPopup = false
        }
    }

    private func userSettingsContent(geometry: GeometryProxy) -> some View {
        let isLandscape = geometry.size.width > geometry.size.height

        // 5. Custom Binding to Intercept Taps
        // This acts as a proxy. When the radio button tries to set the value,
        // we stop it, check if it's different, and show the popup instead.
        let radioBinding = Binding<SaveHistoryOption>(
            get: { self.selectedSaveHistoryOption },
            set: { newValue in
                if newValue != self.selectedSaveHistoryOption {
                    self.pendingOption = newValue
                    self.showConfirmationPopup = true
                }
            }
        )

        return VStack(alignment: .leading, spacing: 30) {
            HStack {
                Text(NSLocalizedString("TOGGLE_BUTTON_TEXT", comment: ""))
                Spacer()
                PillCountingToggleButton(
                    isOn: Binding(
                        get: { isOn },
                        set: { newValue in
                            isOn = newValue
                            AppStorageManager.shared.isPillCountingEnabled =
                                newValue
                            print("Pill counting toggle updated: \(newValue)")
                        }
                    ),
                    onColor: Color(hex: "#FF699B")
                )
            }
            .padding(.horizontal)

            Divider()
                .background(appColors.text)

            Text(NSLocalizedString("SAVE_HISTORY", comment: ""))
                .foregroundStyle(appColors.text)
                .padding(.horizontal)

            if isLandscape {
                HStack(spacing: 20) {
                    ForEach(SaveHistoryOption.allCases) { option in
                        PillCountingRadioButton(
                            option: option,
                            selectedOption: radioBinding,  // Use the intercepted binding
                            label: option.displayText,
                            selectedColor: Color(hex: "#FF699B"),
                            unselectedColor: .gray.opacity(0.5),
                            size: 20,
                            lineWidth: 2,
                            textColor: appColors.text
                        )
                    }
                }
                .padding(.horizontal)

            } else {
                VStack(alignment: .leading, spacing: 45) {
                    ForEach(SaveHistoryOption.allCases) { option in
                        PillCountingRadioButton(
                            option: option,
                            selectedOption: radioBinding,  // Use the intercepted binding
                            label: option.displayText,
                            selectedColor: Color(hex: "#FF699B"),
                            unselectedColor: .gray.opacity(0.5),
                            size: 20,
                            lineWidth: 2,
                            textColor: appColors.text
                        )
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(
            .top,
            isLandscape ? SafeAreaInsets.top + 80 : SafeAreaInsets.top + 50
        )
        .padding(.horizontal, isLandscape ? SafeAreaInsets.leading : 10)
        .background(appColors.primaryBackground)
    }
}

#Preview {
    UserSettingsView()
        .preferredColorScheme(.dark)
}
