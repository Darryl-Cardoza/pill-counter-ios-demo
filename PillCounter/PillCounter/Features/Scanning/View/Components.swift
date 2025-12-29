//
//  Components.swift
//  PillCounter
//
//  Created by HC on 29/12/25.
//

import SwiftUI

// MARK: - CAMERA CONTENT VIEW
// Wraps the UIKit camera view and the ML detection overlay.
struct CameraContentView: View {
    @ObservedObject var cameraService: CameraService
    @EnvironmentObject var appColors: AppColors

    var body: some View {
        ZStack {
            // CAMERA + OVERLAY
            ZStack(alignment: .bottomTrailing) {
                if cameraService.isAuthorized {
                    CameraView(
                        session: cameraService.getSession(),
                        cameraService: cameraService
                    )
                    .ignoresSafeArea()
                    .task { cameraService.start() }
                    .onDisappear { cameraService.stop() }

                    DetectionOverlay(cameraService: cameraService)
                        .ignoresSafeArea()
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                }
            }

        }
    }
}
// MARK: - BOTTOM CONTROLS VIEW
// The container for the pill info, count display, and buttons.
struct BottomControlsView: View {
    let isLandscape: Bool
    let pillScanViewModel: PillScanViewModel
    let cameraService: CameraService
    let appColors: AppColors
    let onAddPill: () -> Void
    let onComplete: () -> Void
    let onTransactionDetailTapped: (PillCountTransactionDetailsEntity) -> Void
    @Binding var showTransactionDetails: Bool
    @Binding var isPaused: Bool

    var body: some View {
        VStack(spacing: 25) {

            // Switch layout based on orientation using separate Views
            if isLandscape {
                LandscapeLayout(
                    pillScanViewModel: pillScanViewModel,
                    cameraService: cameraService,
                    appColors: appColors,
                    isPaused: $isPaused
                )
            } else {
                PortraitLayout(
                    pillScanViewModel: pillScanViewModel,
                    cameraService: cameraService,
                    appColors: appColors,
                    isPaused: $isPaused
                )
            }

            TransactionDetailsScrollView(
                details: pillScanViewModel
                    .currentTransactionTransactionDetails ?? [],
                appColors: appColors,
                onTap: onTransactionDetailTapped
            )
            .opacity(showTransactionDetails ? 1 : 0)
            .allowsHitTesting(showTransactionDetails)

            ActionButtons(
                showTransactionDetails: $showTransactionDetails,
                isLandscape: isLandscape,
                appColors: appColors,
                onAddPill: onAddPill,
                onComplete: onComplete
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(appColors.primaryBackground)
        .cornerRadius(24)
    }
}

// MARK: - PORTRAIT VIEWS
// Layout for Portrait: Count is horizontal, large circle on left.
struct PortraitLayout: View {
    let pillScanViewModel: PillScanViewModel
    @ObservedObject var cameraService: CameraService
    let appColors: AppColors
    @EnvironmentObject var router: Router
    @Binding var isPaused: Bool

    var body: some View {
        HStack(spacing: 30) {
            CircleBadge(
                size: 100,
                strokeWidth: 3,
                outerColor: .pink,
                innerColor: appColors.primary,
                text: "\(cameraService.stableCount)",
                textColor: .white,
                font: .system(size: 24, weight: .bold),
                isAnimated: !isPaused ? true : false
            )

            Spacer()

            VStack(spacing: 10) {
                Text(pillScanViewModel.drugName ?? "Loading...").font(.title3)
                if router.selectedPillScanningType == .FIXED {
                    Text(
                        "\(NSLocalizedString("TOTAL_PILL_COUNT", comment: "")) \(pillScanViewModel.getTotalPillCountOfCurrentTransaction())/\(pillScanViewModel.currentTransaction?.target_count ?? 0)"
                    )
                    .font(.title)
                } else {
                    Text(
                        "\(NSLocalizedString("TOTAL_PILL_COUNT", comment: "")) \(pillScanViewModel.getTotalPillCountOfCurrentTransaction())"
                    )
                    .font(.title)
                }
            }
        }
        .padding(.horizontal, 50)
        .padding(.top, 20)
    }
}

// MARK: - LANDSCAPE LAYOUT
// Layout for Landscape: Count is vertical, text truncated.
struct LandscapeLayout: View {
    let pillScanViewModel: PillScanViewModel
    @ObservedObject var cameraService: CameraService
    let appColors: AppColors
    @EnvironmentObject var router: Router
    @Binding var isPaused: Bool

    var body: some View {
        VStack(spacing: 30) {
            Text(pillScanViewModel.drugName ?? "Loading...")
                .font(.title3).lineLimit(2)
                .multilineTextAlignment(.leading).truncationMode(.tail)
                .padding(.horizontal, 5)

            CircleBadge(
                size: 85,
                strokeWidth: 3,
                outerColor: .pink,
                innerColor: appColors.primary,
                text: "\(cameraService.stableCount)",
                textColor: .white,
                font: .system(size: 24, weight: .bold),
                isAnimated: !isPaused ? true : false
            )

            if router.selectedPillScanningType == .FIXED {
                Text(
                    "\(NSLocalizedString("TOTAL_PILL_COUNT", comment: "")) \(pillScanViewModel.getTotalPillCountOfCurrentTransaction())/\(pillScanViewModel.currentTransaction?.target_count ?? 0)"
                )
                .font(.title)
            } else {
                Text(
                    "\(NSLocalizedString("TOTAL_PILL_COUNT", comment: "")) \(pillScanViewModel.getTotalPillCountOfCurrentTransaction())"
                )
                .font(.title)
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - SCROLLABLE LIST
// Horizontal list of saved pill counts (batches).
struct TransactionDetailsScrollView: View {
    let details: [PillCountTransactionDetailsEntity]
    let appColors: AppColors
    let onTap: (PillCountTransactionDetailsEntity) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(details.indices, id: \.self) { index in
                    let item = details[index]
                    RoundedRectangle(cornerRadius: 8)
                        .fill(appColors.statusChipBackgroundOnPrimary)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text("\(item.pill_count)")
                                .foregroundColor(appColors.secondary)
                                .font(.headline)
                        )
                        .onTapGesture { onTap(item) }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - ACTION BUTTONS
struct ActionButtons: View {
    @Binding var showTransactionDetails: Bool
    let isLandscape: Bool
    let appColors: AppColors
    let onAddPill: () -> Void
    let onComplete: () -> Void

    // 🔹 Local state to control Add button
    @State private var isAddDisabled = false

    var body: some View {
        HStack {
            // History button
            Button {
                showTransactionDetails.toggle()
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundStyle(appColors.primary)
            }

            Spacer()

            Button {
                handleAddPill()
            } label: {
                Image(systemName: "plus.circle")
                    .foregroundColor(
                        isAddDisabled ? .gray : appColors.primary
                    )
            }
            .disabled(isAddDisabled)

            Spacer()

            Button(action: onComplete) {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(appColors.primary)
            }
        }
        .font(.system(size: 32))
        .padding(.horizontal, isLandscape ? 15 : 50)
        .padding(.bottom, 20)
    }

    // MARK: - Add Pill Handler
    private func handleAddPill() {
        guard !isAddDisabled else { return }

        // Call original action
        onAddPill()

        // Disable button
        isAddDisabled = true

        // Re-enable after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isAddDisabled = false
        }
    }
}

// MARK: - CIRCLE BADGE COMPONENT
// A reusable animated circle for displaying counts.
struct CircleBadge: View {
    let size: CGFloat
    let strokeWidth: CGFloat
    let outerColor: Color
    let innerColor: Color
    let text: String
    let textColor: Color
    let font: Font
    let isAnimated: Bool

    @State private var trimValue: CGFloat = 1
    @State private var animationID = UUID()  // ⬅️ animation reset key

    var body: some View {
        ZStack {

            Circle()
                .trim(from: 0, to: trimValue)
                .stroke(
                    outerColor,
                    style: StrokeStyle(
                        lineWidth: strokeWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .id(animationID)  // ⬅️ forces SwiftUI to kill animation
                .onAppear {
                    handleAnimationChange()
                }
                .onChange(of: isAnimated) { _, _ in
                    handleAnimationChange()
                }

            Circle()
                .fill(innerColor)
                .frame(
                    width: size - strokeWidth * 3,
                    height: size - strokeWidth * 3
                )

            Text(text)
                .font(font)
                .foregroundColor(textColor)
                .contentTransition(.numericText())
        }
        .onChange(of: text) { oldValue, newValue in
            if oldValue != newValue {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }

    // MARK: - ANIMATION CONTROL
    private func handleAnimationChange() {
        animationID = UUID()  // ⬅️ kills any running repeatForever

        if isAnimated {
            trimValue = 0
            withAnimation(
                .linear(duration: 1.2).repeatForever(autoreverses: false)
            ) {
                trimValue = 1
            }
        } else {
            // ⛔️ Pause → static full circle
            trimValue = 1
        }
    }
}
