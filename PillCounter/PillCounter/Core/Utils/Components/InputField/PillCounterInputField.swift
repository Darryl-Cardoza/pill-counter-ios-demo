//
//  PillCounterInputField.swift
//  PillCounter
//
//  Created by HC on 03/11/25.
//

import SwiftUI

struct PillCounterInputField: View {
    @EnvironmentObject private var appColors: AppColors
    let imageName: String?
    let placeholder: String
    let disabled: Bool
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var showDropdownMenu: Bool = false
    var dropdownData: [String] = []

    var onSubmit: (() -> Void)? = nil

    var validation: InputValidation = .none
    var maxLength: Int? = nil

    // Detect the current color scheme (light or dark)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            // icon
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(.leading, 15)
                    .foregroundColor(appColors.secondary)

                // Divider
                Rectangle()
                    .fill(Color(uiColor: .separator))
                    .frame(width: 2, height: 25)
            }

            // Text Field
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .onChange(of: text) { oldValue, newValue in
                            text = validateInput(newValue)
                        }
                        .keyboardType(keyboardType)
                        .disabled(disabled)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(.never)
                        .onChange(of: text) { oldValue, newValue in
                            text = validateInput(newValue)                            
                        }
                        .onSubmit {
                            onSubmit?()
                        }
                        .disabled(disabled)
                }
            }
            .padding(.leading, 10)
            .foregroundColor(appColors.text)

            if showDropdownMenu {
                Menu {
                    Picker(selection: $text, label: EmptyView()) {
                        ForEach(dropdownData, id: \.self) { item in
                            Text(item).tag(item)
                        }
                    }
                } label: {
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.caption)
                        .foregroundColor(appColors.text)
                        .padding(.trailing, 16)
                }
            }

        }
        .padding(.vertical, 16)
        .background(appColors.secondaryBackground)
        .cornerRadius(8)
    }

    private func validateInput(_ value: String) -> String {
        var filtered = value

        switch validation {
        case .name:
            filtered = value.filter { $0.isLetter || $0.isWhitespace }

        case .phone:
            filtered = value.filter { $0.isNumber }

        case .npi:
            filtered = value.filter { $0.isNumber }

        case .email:
            filtered = value.lowercased()

        case .none:
            break
        }

        if let maxLength, filtered.count > maxLength {
            filtered = String(filtered.prefix(maxLength))
        }

        return filtered
    }

}
