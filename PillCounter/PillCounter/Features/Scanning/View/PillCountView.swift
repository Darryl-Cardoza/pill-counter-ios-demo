//
//  PillCountView.swift
//  PillCounter
//
//  Created by HC on 13/11/25.
//

import SwiftUI

struct OPillCountView: View {

    // MARK: - ENVIRONMENT
    @Environment(\.isLandscape) private var isLandscape
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appColors: AppColors
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var router: Router
    @EnvironmentObject var pillScanViewModel: PillScanViewModel

    // MARK: - STATE MANAGEMENT
    // @StateObject ensures the camera session survives view updates and rotations.
    @StateObject var cameraService = CameraService()
    @State private var showZeroCountPopup: Bool = false
    @State private var showNoteOption: Bool = false
    @State private var showConfirmCompletionPopup: Bool = false
    @State private var showTransactionDetailPopup: Bool = false
    @State private var errorMessageOfNote: String?
    @State private var selectedTransactionDetail:
        PillCountTransactionDetailsEntity?

    @State private var addNoteSettings: Bool = AppStorageManager.shared
        .isPillCountingEnabled

    @State private var showTransactionHistory: Bool = true

    @State private var showToast: Bool = false
    
    @State private var isZeroOrTargetNotReached: Bool = false

    // MARK: - BODY
    var body: some View {
        ZStack {
            // We use BaseView now because it handles AnyLayout internally,
            // preventing the camera from being destroyed on rotation.
            BaseView(
                topRatio: 0.7,
                topContent: {
                    // Using .id ensures SwiftUI recognizes this as a persistent view
                    CameraContentView(cameraService: cameraService)
                        .id("camera-content")
                        .overlay(rotationObserver)
                        .onTapGesture {
                            cameraService.resetInactivityTimer()
                            cameraService.resumeIfPaused()
                        }
                },
                bottomContent: {
                    controlsContent
                },
                showBackButton: true,
                showHamburgerMenu: false,
                title: NSLocalizedString("PILL_COUNT_HEADER", comment: "")
            )

            if showToast {
                VStack {
                    Spacer()

                    HStack(spacing: 10) {
                        Image("app_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)

                        Text(!isZeroOrTargetNotReached ? "Total transaction count exceeds target." : "No Transaction Found, please start counting pills.")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.bottom, 32)  // distance from bottom
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut, value: showToast)
            }
        }
        .ignoresSafeArea(.keyboard)
        .onDisappear {
            // Clean up transaction reference when leaving
            pillScanViewModel.currentTransaction = nil
            pillScanViewModel.currentTransactionTransactionDetails = nil
            pillScanViewModel.note = ""
        }
        .onTapGesture {
            cameraService.resetInactivityTimer()
            cameraService.resumeIfPaused()
        }
        .onAppear {
            // Load transaction if missing
            initializeTransaction()
            
            print("selected pill count view : \(router.selectedPillScanningType?.rawValue ?? "None")")
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                cameraService.resumeIfPaused()
            case .background, .inactive:
                cameraService.stop()
            @unknown default:
                break
            }
        }
        // MARK: - POPUPS
        .customPopup(isPresented: $showNoteOption) {
            showNoteOptionPopup
        }
        .customPopup(isPresented: $showConfirmCompletionPopup) {
            showConfirmCompletion
        }
        .customPopup(isPresented: $showTransactionDetailPopup) {
            showTransactionDetail
        }
        .customPopup(isPresented: $showZeroCountPopup) {
            zeroCountPopupContent
        }
    }
}

// MARK: - SUBVIEWS & HELPERS
extension OPillCountView {

    // Helper to detect size changes (rotation) and notify the camera service.
    private var rotationObserver: some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.size) { _, _ in
                    cameraService.updateOrientation(
                        UIDevice.current.orientation
                    )
                }
        }
    }

    // The bottom control panel with buttons and lists.
    private var controlsContent: some View {
        BottomControlsView(
            isLandscape: isLandscape,
            pillScanViewModel: pillScanViewModel,
            cameraService: cameraService,
            appColors: appColors,
            onAddPill: {

                cameraService.resetInactivityTimer()
                cameraService.resumeIfPaused()

                guard cameraService.stableCount > 0 else {
                    showZeroCountPopup = true
                    return
                }

                if router.selectedPillScanningType == .FIXED {
                    if pillScanViewModel.getTotalPillCountOfCurrentTransaction()
                        == pillScanViewModel.currentTransaction?.target_count ?? 0
                    {
                        
                        showToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showToast = false
                            isZeroOrTargetNotReached = false
                        }
                        
                        return
                    }
                }

                // 1. Capture the composite image
                var savedPath: String? = nil

                if let compositeImage =
                    cameraService.captureSnapshotWithOverlays()
                {
                    // 2. Save to Disk (Implementation below)
                    savedPath = PhotoFileManager.shared.saveImage(
                        compositeImage)
                }

                // 3. Add transaction with image path
                pillScanViewModel.addTransactionDetailToCurrentTransaction(
                    pillCount: Int32(cameraService.stableCount),
                    imagePath: savedPath
                )
            },
            onComplete: {
                if addNoteSettings {
                    showNoteOption = true
                } else {
                    if pillScanViewModel.getTotalPillCountOfCurrentTransaction() > 0 {
                        showConfirmCompletionPopup = true
                    } else {
                        showToast = true
                        isZeroOrTargetNotReached = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showToast = false
                            isZeroOrTargetNotReached = false
                        }
                    }
                }
            },
            onTransactionDetailTapped: { detail in
                selectedTransactionDetail = detail
                showTransactionDetailPopup = true
            },
            showTransactionDetails: $showTransactionHistory
        )
    }

    // Async task to fetch transaction data on load.
    private func initializeTransaction() {
        Task {
            if pillScanViewModel.currentTransaction == nil {
                await pillScanViewModel.getCurrentTransaction(
                    txnId: userViewModel.currentTransactionTxnId ?? 0
                )
            }
        }
    }

    // Converts a timestamp to a readable date string.
    private func formattedDate(from timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy hh:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - POPUP VIEWS
extension OPillCountView {

    private var zeroCountPopupContent: some View {
        VStack(spacing: 25) {
            HStack {
                Text("INVALID COUNT")
                    .foregroundStyle(appColors.text)
                    .font(.headline)

                Spacer()

                Button {
                    showZeroCountPopup = false
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(appColors.text)
                }
            }

            Text(
                "Cannot add a batch with 0 pills.\nPlease ensure pills are detected by the camera."
            )
            .foregroundStyle(appColors.text)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            PillCountingButton(
                iconName: nil,
                title: "OK",
                textColor: appColors.text,
                backgroundColor: appColors.primary,
                borderColor: .clear,
                font: .system(size: 14, weight: .semibold),
                cornerRadius: 30,
                horizontalPadding: 40,
                verticalPadding: 14,
                iconSize: 0,
                action: {
                    showZeroCountPopup = false
                },
                frameWidth: nil
            )
        }
        .frame(width: 300)
    }

    // Popup showing details of a specific saved count.
    private var showTransactionDetail: some View {
        VStack(spacing: 35) {
            // Header
            HStack {
                Text(
                    "Transaction detail \(selectedTransactionDetail?.txn_details_id ?? 0)"
                )
                Spacer()
                Button {
                    showTransactionDetailPopup = false
                    selectedTransactionDetail = nil
                } label: {
                    Image(systemName: "xmark")
                        .resizable().scaledToFit().frame(width: 16, height: 16)
                        .foregroundStyle(appColors.text)
                }
            }

            // Content (Image + Count)
            HStack(spacing: 30) {
                if let image = selectedTransactionDetail?.image_path,
                    let loadedImage = PhotoFileManager.shared.loadImage(
                        from: image)
                {
                    loadedImage.resizable().scaledToFit().frame(
                        width: 100,
                        height: 80
                    )
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(appColors.text.opacity(0.5), lineWidth: 1)
                        .frame(width: 100, height: 80)
                }

                VStack(spacing: 10) {
                    Text("PILLS COUNT").foregroundStyle(appColors.secondary)
                    CircleBadge(
                        size: 50,
                        strokeWidth: 0,
                        outerColor: .clear,
                        innerColor: appColors.secondary,
                        text: "\(selectedTransactionDetail?.pill_count ?? 0)",
                        textColor: appColors.text,
                        font: .system(size: 18, weight: .bold)
                    )
                    Text(
                        "\(formattedDate(from: selectedTransactionDetail?.created_at ?? 0))"
                    )
                    .foregroundStyle(appColors.text).font(.system(size: 14))
                }
            }

            // Actions (Delete / OK)
            HStack {
                PillCountingButton(
                    iconName: nil,
                    title: "DELETE",
                    textColor: appColors.secondary,
                    backgroundColor: .clear,
                    borderColor: appColors.secondary,
                    font: .system(size: 12, weight: .semibold),
                    cornerRadius: 30,
                    horizontalPadding: 32,
                    verticalPadding: 18,
                    iconSize: 0,
                    action: {
                        showTransactionDetailPopup = false
                        pillScanViewModel
                            .softDeleteCurrentTransactionSelectedTransactionDetail(
                                txnDetailId: selectedTransactionDetail?
                                    .txn_details_id ?? 0
                            )
                    }
                )
                PillCountingButton(
                    iconName: nil,
                    title: "OK",
                    textColor: appColors.text,
                    backgroundColor: appColors.secondary,
                    borderColor: appColors.secondary,
                    font: .system(size: 12, weight: .semibold),
                    cornerRadius: 30,
                    horizontalPadding: 32,
                    verticalPadding: 18,
                    iconSize: 0,
                    action: { showTransactionDetailPopup = false }
                )
            }
        }
        .frame(width: 300)
    }
    
    private var isTransactionCompleted: Bool {
        pillScanViewModel.getTotalPillCountOfCurrentTransaction()
        == (pillScanViewModel.currentTransaction?.target_count ?? 0)
    }
    
    private var confirmationMessage: String {
        let status = isTransactionCompleted || router.selectedPillScanningType == .REGULAR ? "COMPLETED" : "PENDING"
        
        let message = isTransactionCompleted || router.selectedPillScanningType == .REGULAR ? "Are you sure you want to mark this transaction as \(status)" : "Target not reached. This transaction will be marked as \(status)."

        return message
    }

    // Popup confirming session end if target not met.
    private var showConfirmCompletion: some View {
        ConfirmationDialogue(
            title: "Confirm Completion",
            message: confirmationMessage,
            cancelButtonText: "CANCEL",
            confirmButtonText: "OK",
            onCancel: {
                showNoteOption = false
                showConfirmCompletionPopup = false
            },
            onConfirm: {
                showNoteOption = false
                showConfirmCompletionPopup = false
                router.navigateBack()
                if isTransactionCompleted || router.selectedPillScanningType == .REGULAR {
                    Task(priority: .background, operation: {
                        await userViewModel.completeTheSelectedTransaction(txnId: pillScanViewModel.currentTransaction?.txn_id ?? 0, countType: router.selectedPillScanningType ?? .FIXED)
                    })
                }
            }
        )
    }

    // Popup for adding a note before saving.
    private var showNoteOptionPopup: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                Text("ADD NOTE").foregroundStyle(appColors.text)
                Spacer()
                Button {
                    showNoteOption = false
                    showConfirmCompletionPopup = false
                } label: {
                    Image(systemName: "xmark")
                        .resizable().scaledToFit().frame(width: 16, height: 16)
                        .foregroundStyle(appColors.text)
                }
            }

            PillCounterTextEditor(
                imageName: nil,
                placeholder: "",
                disabled: false,
                text: $pillScanViewModel.note
            )

            if let errorMessageOfNote = errorMessageOfNote {
                Text(errorMessageOfNote).foregroundStyle(Color.red).padding(
                    .top,
                    -20
                )
            }

            HStack {
                PillCountingButton(
                    iconName: nil,
                    title: "SKIP",
                    textColor: appColors.text,
                    backgroundColor: appColors.primaryBackground,
                    borderColor: appColors.primary,
                    font: .system(size: 12, weight: .semibold),
                    cornerRadius: 30,
                    horizontalPadding: 32,
                    verticalPadding: 14,
                    iconSize: 0,
                    action: {
                        showNoteOption = false
                        if (pillScanViewModel.currentTransaction?.target_count
                            ?? 0)
                            > pillScanViewModel
                            .getTotalPillCountOfCurrentTransaction()
                        {
                            showConfirmCompletionPopup = true
                        } else if pillScanViewModel.currentTransaction?
                            .target_count ?? 0
                            == pillScanViewModel
                            .getTotalPillCountOfCurrentTransaction()
                        {

                            Task {
                                await userViewModel
                                    .completeTheSelectedTransaction(
                                        txnId: pillScanViewModel
                                            .currentTransaction?.txn_id ?? 0,
                                        countType: router
                                            .selectedPillScanningType ?? .FIXED)
                            }
                        }
                    },
                    frameWidth: nil
                )

                PillCountingButton(
                    iconName: nil,
                    title: "SAVE",
                    textColor: appColors.text,
                    backgroundColor: appColors.primary,
                    borderColor: .clear,
                    font: .system(size: 12, weight: .regular),
                    cornerRadius: 30,
                    horizontalPadding: 32,
                    verticalPadding: 14,
                    iconSize: 0,
                    action: {
                        showNoteOption = false
                        Task(priority: .background) {
                            pillScanViewModel.updateNoteForCurrentTransaction(
                                txn_id: pillScanViewModel.currentTransaction?
                                    .txn_id ?? 0,
                                note: pillScanViewModel.note
                            )
                        }
                        showConfirmCompletionPopup = true
                    },
                    frameWidth: nil
                )
            }
        }
        .frame(width: 250)
    }
}

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

            // 🔹 PAUSED OVERLAY (CENTER)
            if cameraService.isPausedDueToInactivity {
                pausedOverlay
            }
        }
    }
}
extension CameraContentView {

    fileprivate var pausedOverlay: some View {
        Color.black.opacity(0.6)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 16) {

                    Text("COUNTING PAUSED DUE TO INACTIVITY.")
                        .foregroundStyle(appColors.text)

                    Button {
                        cameraService.resumeIfPaused()
                        cameraService.resetInactivityTimer()
                    } label: {
                        Text("Resume")
                            .font(.headline)
                            .foregroundColor(appColors.text)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 20)
                            .background(appColors.secondary)
                            .cornerRadius(30)
                    }
                }
            )
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

    var body: some View {
        VStack(spacing: 25) {

            // Switch layout based on orientation using separate Views
            if isLandscape {
                LandscapeLayout(
                    pillScanViewModel: pillScanViewModel,
                    cameraService: cameraService,
                    appColors: appColors
                )
            } else {
                PortraitLayout(
                    pillScanViewModel: pillScanViewModel,
                    cameraService: cameraService,
                    appColors: appColors
                )
            }

            if showTransactionDetails {
                TransactionDetailsScrollView(
                    details: pillScanViewModel
                        .currentTransactionTransactionDetails
                        ?? [],
                    appColors: appColors,
                    onTap: onTransactionDetailTapped
                )
            }

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

// MARK: - LAYOUT VIEWS
// Layout for Portrait: Count is horizontal, large circle on left.
struct PortraitLayout: View {
    let pillScanViewModel: PillScanViewModel
    @ObservedObject var cameraService: CameraService
    let appColors: AppColors
    @EnvironmentObject var router: Router

    var body: some View {
        HStack(spacing: 30) {
            CircleBadge(
                size: 100,
                strokeWidth: 3,
                outerColor: .pink,
                innerColor: appColors.primary,
                text: "\(cameraService.stableCount)",
                textColor: .white,
                font: .system(size: 24, weight: .bold)
            )

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
        .padding(.top, 20)
    }
}

// Layout for Landscape: Count is vertical, text truncated.
struct LandscapeLayout: View {
    let pillScanViewModel: PillScanViewModel
    @ObservedObject var cameraService: CameraService
    let appColors: AppColors
    @EnvironmentObject var router: Router

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
                font: .system(size: 24, weight: .bold)
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

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Circle().stroke(outerColor, lineWidth: strokeWidth).frame(
                width: size,
                height: size
            )
            Circle().fill(innerColor)
                .frame(
                    width: size - strokeWidth * 3,
                    height: size - strokeWidth * 3
                )
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(
                    .easeInOut(duration: 0.3).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            Text(text).font(font).foregroundColor(textColor).contentTransition(
                .numericText()
            )
        }
        .onAppear { isAnimating = true }
        .onChange(of: text) { oldValue, newValue in
            if oldValue != newValue {
                let haptic = UIImpactFeedbackGenerator(style: .light)
                haptic.impactOccurred()
            }
        }
    }
}
