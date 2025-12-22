//
//  PillCounterApp.swift
//  PillCounter
//
//  Created by HC on 31/10/25.
//

import SwiftUI

@main
struct PillCounterApp: App {
    @ObservedObject private var router = Router()
    @ObservedObject private var loginViewModel = LoginViewModel()
    @ObservedObject private var userViewModel = UserViewModel()
    @ObservedObject private var appColors = AppColors.shared
    @ObservedObject private var confirmationDialogueManager =
        ConfirmationDialogueManager()
    @ObservedObject private var pillScanViewModel = PillScanViewModel()

    var body: some Scene {
        WindowGroup {
            //            DashboardView()

            //            HamburgerMenuView()
            //                .environmentObject(router)

            AppNavigation()
                .font(.system(size: 16))  // declaring global value for font size.
                .environment(\.dynamicTypeSize, .medium)  // blocks the app sizing for the fonts.
                .environmentObject(router)
                .environmentObject(loginViewModel)
                .environmentObject(userViewModel)
                .environmentObject(appColors)
                .environmentObject(confirmationDialogueManager)
                .environmentObject(pillScanViewModel)
                .task {
                    // 1. Load Theme
                    userViewModel.loadMobileThemeSettings()

                    // 2. Perform History Cleanup in background
                    // We wrap in a Task to ensure it doesn't block the UI immediately
                    Task.detached(priority: .background) {
                        // Since we are using mainThreadContext in the singleton,
                        // we should bounce back to main actor or use performAndWait.
                        // However, assuming your PillsDataLocalStorage handles context safety:
                        await MainActor.run {
                            print("Cleaning up baba.")
                            PillsDataLocalStorage.shared.cleanUpOldHistory()
                        }
                    }
                }
        }
    }
}
