//
//  CameraViewModel.swift
//  PillCounter
//
//  Created by HC on 14/11/25.
//

import AVFoundation
import Foundation
import UIKit

class CameraViewModel: NSObject, ObservableObject,
                       AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate
{
    @Published var scannedCode: String = ""
    @Published var codeType: String = ""
    @Published var isAuthorized = false
    @Published var error: String?

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let metadataOutput = AVCaptureMetadataOutput()
    private let photoOutput = AVCapturePhotoOutput()

    private var photoCaptureCompletion: ((UIImage?) -> Void)?
    
    var previewLayer: AVCaptureVideoPreviewLayer?

    override init() {
        super.init()
        checkPermissions()
    }

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted { self?.setupCamera() }
                }
            }
        default:
            isAuthorized = false
            error = "Camera access denied"
        }
    }

    private func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }  // IMPORTANT

            self.session.sessionPreset = .photo

            guard
                let videoDevice = AVCaptureDevice.default(
                    .builtInWideAngleCamera, for: .video, position: .back),
                let videoInput = try? AVCaptureDeviceInput(device: videoDevice)
            else {
                DispatchQueue.main.async { self.error = "Cannot access camera" }
                return
            }

            if self.session.canAddInput(videoInput) {
                self.session.addInput(videoInput)
                self.videoDeviceInput = videoInput
            }

            // Output: Metadata (Barcodes)
            if self.session.canAddOutput(self.metadataOutput) {
                self.session.addOutput(self.metadataOutput)
                self.metadataOutput.setMetadataObjectsDelegate(
                    self, queue: DispatchQueue.main)

                self.metadataOutput.metadataObjectTypes = [
                    .qr, .ean8, .ean13, .pdf417, .code128,
                    .code39, .code93, .upce, .aztec, .dataMatrix,
                    .interleaved2of5, .itf14,
                ]
            }
            
            // Output: Photo (Images) - 2. Add Photo Output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }
        }
    }

    func startSession() {
        sessionQueue.async {
            guard !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async {
            guard self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    func getSession() -> AVCaptureSession {
        return session
    }

    func updateOrientation(_ orientation: UIDeviceOrientation) {
        guard let connection = previewLayer?.connection else { return }

        if connection.isVideoRotationAngleSupported(0) {
            connection.videoRotationAngle = orientation.videoRotationAngle
        }
    }
    
    // MARK: - 3. Capture Image Method
    func captureImage(completion: @escaping (UIImage?) -> Void) {
        // Store the completion handler
        self.photoCaptureCompletion = completion
        
        // Configure settings
        let settings = AVCapturePhotoSettings()
        if let photoOutputConnection = photoOutput.connection(with: .video) {
            // Match the preview orientation for the saved image
            if let previewLayer = previewLayer, let previewConnection = previewLayer.connection {
                photoOutputConnection.videoRotationAngle = previewConnection.videoRotationAngle
            }
        }
        
        // Capture
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    // MARK: - AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            print("❌ Error capturing photo: \(String(describing: error))")
            DispatchQueue.main.async { self.photoCaptureCompletion?(nil) }
            return
        }
        
        print("📸 [CameraVM] Image captured successfully")
        DispatchQueue.main.async {
            self.photoCaptureCompletion?(image)
        }
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            let metadataObject = metadataObjects.first
                as? AVMetadataMachineReadableCodeObject,
            let stringValue = metadataObject.stringValue
        else { return }

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        scannedCode = stringValue
        codeType = metadataObject.type.rawValue
    }
}

extension UIDeviceOrientation {
    var videoRotationAngle: CGFloat {
        switch self {
        case .landscapeLeft: 0
        case .portrait: 90
        case .landscapeRight: 180
        case .portraitUpsideDown: 270
        default: 90
        }
    }
}
