//
//  LoginOtpVerificationView.swift
//  PillCounter
//
//  Created by HC on 03/11/25.
//

import SwiftUI

struct LoginOtpVerificationView: View {
    // MARK: PROPERTIES
    // environment objects
    @FocusState private var isKeyboardActive: Bool
    @EnvironmentObject private var appColors: AppColors
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        ZStack {
            BaseView(
                topRatio: 0.5,
                topContent: {
                    LoginLogoView()
                },
                bottomContent: {
                    OtpVerification()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(appColors.primaryBackground)
                        .cornerRadius(24)
                        .keyboardAdaptive()
                },
                showBackButton: true,
                confirmBack: true
            )
            .onTapGesture {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder), to: nil,
                    from: nil,
                    for: nil)
            }

            if loginViewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()

                    PillCountingLoader()
                }
            }
        }
        .onAppear {
            loginViewModel.startResendTimer()
        }
    }
}

// MARK: OTP VERIFICATION
struct OtpVerification: View {

    // Properties
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var appColors: AppColors

    var body: some View {
        VStack(spacing: 35) {
            VStack(spacing: 0) {
                Text("CODE_SENT_TEXT")
                    .foregroundStyle(appColors.text)
                    .font(.system(size: 18))

                Text(Formatter.maskEmail(loginViewModel.userEmail))
                    .foregroundStyle(appColors.text)
                    .font(.system(size: 18))
            }

            OTPInputView(otp: $loginViewModel.otp)
            
            if let errorMessage = loginViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(loginViewModel.resendOTPSent ? Color.green : Color.red)
                    .font(.system(size: 14))
            }

            HStack(spacing: 6) {
                Text("RESEND_CODE")
                    .foregroundStyle(
                        loginViewModel.isResendDisabled
                        ? Color.gray
                        : Color.pink
                    )
                
                if loginViewModel.isResendDisabled {
                    Text(loginViewModel.resendTimerText)
                        .foregroundStyle(Color.gray)
                        .font(.system(size: 14))
                }
            }
            .onTapGesture {
                guard !loginViewModel.isResendDisabled else { return }
                
                Task {
                    await loginViewModel.resendOTP()
                }
            }

            Button {
                // some action to be taken to verify the otp with the backend.
                // so here we will have to call the view model function and from the view model function we will call the respository api.
                
                Task {
                    await loginViewModel.verifyOTP()
                    
                    // after successfull otp verification need to call the get user.
                    // also if the user is new then directly load the profile screen to the user.
                    
                    if loginViewModel.isOtpVerificationSuccess {
                        router.setRoot(
                            to: .authentication(
                                .login(.dashboard(.dashboardHome))))
                    }
                }
                
            } label: {
                Text("VERIFY_BUTTON")
                    .foregroundColor(appColors.text)
                    .fontWeight(.semibold)
                    .padding(18)
                    .padding(.horizontal)
                    .background(
                        (!loginViewModel.isOtpComplete || loginViewModel.isLoading)
                        ? Color.gray.opacity(0.3)
                        : appColors.primary
                    )
                    .cornerRadius(50)
                    .frame(maxWidth: .infinity)
            }
            .disabled(loginViewModel.otp.joined().count < 4 || loginViewModel.isLoading)

        }
        .padding(.vertical, 32)
        .onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                for: nil)
        }

    }
}

// MARK: - OTP INPUT VIEW
struct OTPInputView: View {

    // MARK: - PUBLIC API
    @Binding var otp: [String]
    let reverse: Bool

    // MARK: - ENVIRONMENT
    @EnvironmentObject private var appColors: AppColors
    @EnvironmentObject var loginViewModel: LoginViewModel
    @FocusState private var isKeyboardFocused: Bool

    // MARK: - INTERNAL STATE
    @State private var text: String = ""

    // MARK: - INIT
    init(otp: Binding<[String]>, reverse: Bool = false) {
        self._otp = otp
        self.reverse = reverse
    }

    // MARK: - BODY
    var body: some View {
        ZStack {

            // LAYER 1: Invisible TextField (input capture)
            TextField("", text: $text)
                .focused($isKeyboardFocused)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .onChange(of: text) { _, newValue in
                    handleInput(newValue)
                    loginViewModel.errorMessage = nil
                }
                .onAppear {
                    configureInitialState()
                }

            // LAYER 2: Visual Boxes
            HStack(spacing: 15) {
                ForEach(0..<4, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(appColors.inputBackground)
                            .frame(width: 60, height: 80)

                        RoundedRectangle(cornerRadius: 10)
                            .stroke(borderColor(for: index), lineWidth: 2)
                            .frame(width: 60, height: 80)

                        Text(displayChar(at: index))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(appColors.text)
                    }
                    .onTapGesture {
                        isKeyboardFocused = true
                    }
                }
            }
        }
    }

    // MARK: - INITIAL CONFIGURATION
    private func configureInitialState() {
        if reverse {
            otp = Array(repeating: "0", count: 4)
            text = ""
        } else {
            text = otp.joined()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isKeyboardFocused = true
        }
    }

    // MARK: - INPUT HANDLING
    private func handleInput(_ newValue: String) {

        let filtered = newValue.filter { $0.isNumber }
        if filtered != newValue {
            text = filtered
            return
        }

        if filtered.count > 4 {
            text = String(filtered.prefix(4))
            return
        }

        text = filtered

        var updatedOtp = Array(repeating: reverse ? "0" : "", count: 4)

        if reverse {
            let chars = Array(text)
            let startIndex = 4 - chars.count

            for (i, char) in chars.enumerated() {
                updatedOtp[startIndex + i] = String(char)
            }
        } else {
            for (i, char) in text.enumerated() {
                updatedOtp[i] = String(char)
            }
        }

        otp = updatedOtp

        if text.count == 4 {
            isKeyboardFocused = false
        }
    }

    // MARK: - DISPLAY LOGIC
    private func displayChar(at index: Int) -> String {
        reverse ? otp[index] : (index < text.count ? String(text[text.index(text.startIndex, offsetBy: index)]) : "")
    }

    // MARK: - BORDER STYLING
    private func borderColor(for index: Int) -> Color {
        guard isKeyboardFocused else { return .clear }

        if reverse {
            let activeIndex = max(0, 3 - text.count)
            return index == activeIndex ? Color.blue.opacity(0.8) : .clear
        } else {
            if index == text.count { return Color.blue.opacity(0.8) }
            if index == 3 && text.count == 4 { return Color.blue.opacity(0.8) }
        }

        return .clear
    }
}

