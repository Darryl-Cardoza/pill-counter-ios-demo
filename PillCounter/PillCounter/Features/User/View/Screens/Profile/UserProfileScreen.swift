//
//  UserProfileScreen.swift
//  PillCounter
//
//  Created by HC on 06/11/25.
//

import SwiftUI

struct UserProfileScreen: View {

    @Environment(\.isLandscape) var isLandscape
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var appColors: AppColors
    
    @AppStorage(AppStorageManager.AppStorageKeys.isNewUser) var isNewUser:
        Bool = true

    @State private var firstName: String = ""
    var body: some View {
        ZStack {
            BaseView(
                topRatio: 1.0,
                topContent: {
                    if !isLandscape {
                        profileScreenPotrait()
                            .frame(
                                maxWidth: .infinity, maxHeight: .infinity,
                                alignment: .leading
                            )
                            .background(appColors.primaryBackground)
                    } else {
                        profileScreenLandscape()
                            .frame(
                                maxWidth: .infinity, maxHeight: .infinity,
                                alignment: .leading
                            )
                            .background(appColors.primaryBackground)
                    }
                },
                bottomContent: {
                    EmptyView()
                },
                showBackButton: !isNewUser,
                showHamburgerMenu: false,
                title: NSLocalizedString("PROFILE", comment: "")
            )
            
            if userViewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    
                    PillCountingLoader()
                }
            }
        }
        .onAppear {
            Task {
                await userViewModel.getUser()
            }
        }
    }

    private var leftProfileColumn: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("FIRST_NAME", comment: ""))
                .foregroundStyle(appColors.text)

            PillCounterInputField(
                imageName: nil,
                placeholder: "",
                disabled: false,
                text: $userViewModel.firstName,
                validation: .name,
                maxLength: 30
            )

            Text(NSLocalizedString("LAST_NAME", comment: ""))
                .foregroundStyle(appColors.text)

            PillCounterInputField(
                imageName: nil,
                placeholder: "",
                disabled: false,
                text: $userViewModel.lastName,
                validation: .name,
                maxLength: 30
            )

            Text(NSLocalizedString("PHARMACY_NAME", comment: ""))
                .foregroundStyle(appColors.text)

            PillCounterInputField(
                imageName: nil,
                placeholder: "",
                disabled: false,
                text: $userViewModel.pharmacyName,
                validation: .none
            )
        }
    }

    private var rightProfileColumn: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("PHONE_NUMBER", comment: ""))
                .foregroundStyle(appColors.text)

            PillCounterInputField(
                imageName: nil,
                placeholder: "",
                disabled: false,
                text: $userViewModel.phoneNumber,
                keyboardType: .phonePad,
                validation: .phone
            )

            Text(NSLocalizedString("EMAIL", comment: ""))
                .foregroundStyle(appColors.text)

            PillCounterInputField(
                imageName: nil,
                placeholder: "",
                disabled: true,
                text: $userViewModel.email
            )

            Text(NSLocalizedString("NPI_ID", comment: ""))
                .foregroundStyle(appColors.text)

            PillCounterInputField(
                imageName: nil,
                placeholder: "",
                disabled: false,
                text: $userViewModel.npiID,
                keyboardType: .phonePad,
                validation: .phone
            )
        }
    }

    private var actionButtons: some View {
        HStack {
            ForEach(["DELETE", "SKIP", "SAVE"], id: \.self) { title in
                PillCountingButton(
                    iconName: nil,
                    title: NSLocalizedString(title, comment: ""),
                    textColor: title != "SAVE"
                        ? appColors.primary : appColors.text,
                    backgroundColor: title != "SAVE"
                        ? .clear : appColors.primary,
                    borderColor: title != "SAVE"
                        ? appColors.primary : .clear,
                    font: .system(size: 16, weight: .semibold),
                    cornerRadius: 40,
                    horizontalPadding: 22,
                    verticalPadding: 15,
                    iconSize: 24,
                    action: {
                        handleActionButtonTap(title)
                    }
                )
                // ensure each button takes equal space
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func handleActionButtonTap(_ title: String) {
        switch title {
        case "DELETE":
            print("🗑 DELETE tapped")
        // handle delete logic
        case "SKIP":
            print("✏️ EDIT tapped")
            router.navigateBack()
        // handle enabling edit mode
        case "SAVE":
            print("💾 SAVE tapped")
            Task {
                await userViewModel.updateUserProfile()

                if userViewModel.isProfileUpdated {
                    // setting the is new user as false for new user redirections.
                    isNewUser = false
                    userViewModel.isProfileUpdated = false
                    router.navigateBack()
                }
            }
        default:
            break
        }
    }

    private func profileScreenLandscape() -> some View {
        VStack(spacing: 20) {
            Spacer().frame(height: SafeAreaInsets.top + 20)
            HStack(alignment: .top, spacing: 12) {
                leftProfileColumn

                rightProfileColumn
            }
            .padding(.horizontal)

            actionButtons
                .padding(.horizontal)

        }
        .padding(.horizontal, SafeAreaInsets.leading)
    }

    private func profileScreenPotrait() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer().frame(height: 100)
            leftProfileColumn
            rightProfileColumn
            Spacer()

            actionButtons
                .padding(.horizontal)
                .padding(.bottom)
                .frame(maxWidth: .infinity)

        }
        .background(appColors.primaryBackground)
        .padding(.horizontal)
    }
}

#Preview {
    let userViewModel = UserViewModel()
    UserProfileScreen()
        .preferredColorScheme(.dark)
        .environmentObject(userViewModel)
}
