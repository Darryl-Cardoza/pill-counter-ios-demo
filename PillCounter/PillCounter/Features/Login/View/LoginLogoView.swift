//
//  Login.swift
//  PillCounter
//
//  Created by HC on 31/10/25.
//

import SwiftUI

struct LoginLogoView: View {
    
    @EnvironmentObject private var appColors: AppColors
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                appColors.secondaryBackground
                    .ignoresSafeArea()

                VStack {
                    Spacer(minLength: geometry.safeAreaInsets.top)

                    Spacer()

                    Image("app_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: geometry.size.width * 0.25,
                            height: geometry.size.width * 0.25
                        )

                    Text("APP_NAME")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#01BBD3"))

                    Spacer()

                    VStack(spacing: 8) {
                        Text("COMPANY_NAME")
                            .font(.subheadline)
                            .foregroundColor(appColors.text)
                        Text("\(NSLocalizedString("VERSION", comment: "")) 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(appColors.text)
                    }
                    .padding(.vertical)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
