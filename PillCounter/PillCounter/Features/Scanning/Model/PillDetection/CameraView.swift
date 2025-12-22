//
//  CameraView.swift
//  PillCounter
//
//  Created by HC on 24/11/25.
//

import AVFoundation
import SwiftUI

struct CameraView: UIViewRepresentable {
    let session: AVCaptureSession
    @ObservedObject var cameraService: CameraService

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.session = session

        cameraService.previewLayer = view.previewLayer

        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        // not doing anything over here.
    }
}

class PreviewView: UIView {

    var session: AVCaptureSession? {
        didSet {
            previewLayer.session = session
        }
    }

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        previewLayer.videoGravity = .resizeAspectFill
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}

struct DetectionOverlay: View {
    // We need the full service to access the previewLayer for conversion
    @ObservedObject var cameraService: CameraService
    @EnvironmentObject var appColors: AppColors

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                // If the preview layer isn't ready, we can't draw correctly yet
                if cameraService.previewLayer != nil {

                    ForEach(
                        Array(cameraService.detections.enumerated()),
                        id: \.offset
                    ) { index, det in

                        // 1. Convert ML coordinates to Screen coordinates using the Layer
                        let screenRect = getScreenRect(for: det)

                        // 3. Draw Badge (Calculate center based on the NEW screenRect)
                        let badgeSize: CGFloat = 20
                        let badgeX = screenRect.midX
                        let badgeY = screenRect.midY

                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.8))
                                .stroke(Color.white, lineWidth: 2)

                            Text("\(index + 1)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(appColors.text)
                        }
                        .frame(width: badgeSize, height: badgeSize)
                        .position(x: badgeX, y: badgeY)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Coordinate Math
    private func getScreenRect(for det: DetectionResult) -> CGRect {
        guard let layer = cameraService.previewLayer else { return .zero }

        // 1. Normalize the coordinates (0.0 to 1.0) based on the IMAGE size (e.g. 1920x1080)
        // This creates a rectangle relative to the camera sensor.
        let normalizedRect = CGRect(
            x: det.rect.origin.x / det.originalFrameSize.width,
            y: det.rect.origin.y / det.originalFrameSize.height,
            width: det.rect.width / det.originalFrameSize.width,
            height: det.rect.height / det.originalFrameSize.height
        )

        // 2. Ask the PreviewLayer to map that normalized rectangle to the View
        //
        // This function knows that in Portrait mode, the sides of the image are cropped out.
        // It shifts the X/Y coordinates automatically to match the screen.
        let convertedRect = layer.layerRectConverted(
            fromMetadataOutputRect: normalizedRect)

        return convertedRect
    }
}
