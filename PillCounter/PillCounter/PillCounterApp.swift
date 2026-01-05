//
//  PillCounterApp.swift
//  PillCounter
//
//  Created by HC on 31/10/25.
//

import SwiftUI

@main
struct PillCounterApp: App {

    // MARK: - ENVIRONMENT
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - APP STATE
    @StateObject private var securityState = AppSecurityState()

    @ObservedObject private var router = Router()
    @ObservedObject private var loginViewModel = LoginViewModel()
    @ObservedObject private var userViewModel = UserViewModel()
    @ObservedObject private var appColors = AppColors.shared
    @ObservedObject private var confirmationDialogueManager =
        ConfirmationDialogueManager()
    @ObservedObject private var pillScanViewModel = PillScanViewModel()

    init() {
        if SecurityManager.isDeviceCompromised() {
            _securityState = StateObject(
                wrappedValue: {
                    let state = AppSecurityState()
                    state.isSecure = false
                    return state
                }()
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {

                // 1️⃣ Security violation (highest priority)
                if !securityState.isSecure {
                    SecurityViolationView()
                        .environmentObject(appColors)

                    // 2️⃣ Force Update
                } else if userViewModel.isForceUpdate {
                    ForceUpdateView()
                        .environmentObject(appColors)

                    // 3️⃣ Maintenance Mode
                } else if userViewModel.isMaintenance {
                    MaintenaceView()
                        .environmentObject(appColors)

                    // 4️⃣ Normal App
                } else {
                    AppNavigation()
                        .font(.system(size: 16))
                        .environment(\.dynamicTypeSize, .medium)
                        .environmentObject(router)
                        .environmentObject(loginViewModel)
                        .environmentObject(userViewModel)
                        .environmentObject(appColors)
                        .environmentObject(confirmationDialogueManager)
                        .environmentObject(pillScanViewModel)
                        .onAppear {
                            startSecurityMonitoring()
                        }
                        .task {
                            userViewModel.loadMobileThemeSettings()

                            Task.detached(priority: .background) {
                                await MainActor.run {
                                    PillsDataLocalStorage.shared
                                        .cleanUpOldHistory()
                                }
                            }
                        }
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                handleScenePhaseChange(newPhase)
            }
        }

    }
}

// MARK: - Security Handling
extension PillCounterApp {

    private func startSecurityMonitoring() {
        SecurityMonitor.shared.startMonitoring {
            DispatchQueue.main.async {
                securityState.isSecure = false
                SecurityMonitor.shared.stopMonitoring()
            }
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            if SecurityManager.isDeviceCompromised() {
                securityState.isSecure = false
            } else {
                startSecurityMonitoring()
            }
        case .background, .inactive:
            SecurityMonitor.shared.stopMonitoring()
        @unknown default:
            break
        }
    }
}
