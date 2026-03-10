
# MobRite PillCounter iOS

PillCounter is an **iOS pharmacy workflow application** designed to assist pharmacists in accurately **verifying medications, counting pills, and dispensing prescriptions** with minimal human error.

The application integrates **barcode scanning, NDC validation, automated pill counting, controlled drug verification, and vial documentation** to ensure safe dispensing and compliance with pharmacy regulations.

Built with **SwiftUI**, the system is optimized for modern pharmacy workflows and integrates with **Pharmacy Management Systems (PMS)**.

---

# Key Features

## Barcode / QR Code Scanning
- Scan medication containers using **barcode, QR, or GTIN codes**
- Decode and extract **NDC (National Drug Code)** information
- Real-time validation of scanned drugs

## NDC Verification
- Compare scanned NDC with the **expected NDC from PMS**
- Prevent dispensing incorrect medication
- Error feedback when mismatch occurs

## Pill Counting
- Capture pill images using device camera
- Automated pill detection and counting
- Compare counted quantity with **prescribed quantity**

## Controlled Drug Workflow
For controlled substances the system adds additional safety steps:

- Mandatory verification
- Optional **double counting**
- User confirmation steps
- Audit trail support

## Vial Capture Verification
- Capture image of the final vial
- Ensures correct labeling and packaging
- Documentation for pharmacy compliance

## Transaction Management
- Each prescription runs as a **transaction**
- Maintains workflow state across steps
- Cleans state after completion or cancellation

---

# Workflow

## 1. Prescription Received
Prescription data is received from the **Pharmacy Management System (PMS)** including:

- Drug NDC
- Prescribed pill count
- Transaction information

## 2. Medication Scan
Pharmacist scans the medication container barcode.

System extracts:
- GTIN
- NDC
- Product identifier

## 3. Drug Verification
The scanned NDC is compared against the **expected PMS NDC**.

Possible outcomes:
- Valid drug → Continue workflow
- Invalid drug → Display mismatch error

## 4. Pill Counting
The system captures pill images and performs automated counting.

Two values are tracked:
- **Target Count** → From PMS
- **Detected Count** → From camera processing

## 5. Controlled Drug Double Count (Optional)
For certain schedules:

- A second count is required
- Both counts must match before proceeding

## 6. Vial Image Capture
Pharmacist captures image of filled vial for verification.

## 7. Dispensing Complete
The prescription is verified and ready for dispensing.

---

# Tech Stack

| Technology | Purpose |
|--------|--------|
| SwiftUI | User Interface |
| AVFoundation | Camera & scanning |
| CoreData | Local storage |
| REST APIs | PMS integration |
| Barcode Decoders | GTIN / NDC parsing |

---

# Architecture

The app follows a **MVVM architecture**.

```

View
↓
ViewModel
↓
Services
↓
Models / Storage

```

---

# Project Structure

```

PillCounter
│
├── App
│   ├── PillCounterApp.swift
│   └── AppInitializer.swift
│
├── Views
│   │
│   ├── Scan
│   │   ├── BarcodeScannerView.swift
│   │   ├── CameraPreviewView.swift
│   │   └── ScanOverlayView.swift
│   │
│   ├── Counting
│   │   ├── PillCountingView.swift
│   │   ├── PillCountingPreview.swift
│   │   └── CountingResultView.swift
│   │
│   ├── ControlledDrug
│   │   ├── ControlledStepView.swift
│   │   ├── DoubleCountView.swift
│   │   └── VerificationView.swift
│   │
│   ├── Vial
│   │   ├── VialCaptureView.swift
│   │   └── VialPreviewView.swift
│   │
│   ├── Components
│   │   ├── ConfirmationDialogue.swift
│   │   ├── PrimaryButton.swift
│   │   └── StatusIndicator.swift
│   │
│   └── Shared
│       └── LoadingView.swift
│
├── ViewModels
│   │
│   ├── PillScanViewModel.swift
│   ├── TransactionViewModel.swift
│   └── UserViewModel.swift
│
├── Services
│   │
│   ├── Camera
│   │   ├── CameraService.swift
│   │   └── CameraManager.swift
│   │
│   ├── Scanner
│   │   ├── BarcodeScannerService.swift
│   │   └── BarcodeDecoder.swift
│   │
│   ├── Network
│   │   ├── APIClient.swift
│   │   └── DrugValidationService.swift
│   │
│   └── PillDetection
│       ├── PillDetectionService.swift
│       └── ImageProcessing.swift
│
├── Models
│   │
│   ├── Drug
│   │   └── DrugModel.swift
│   │
│   ├── Transaction
│   │   ├── Transaction.swift
│   │   └── TransactionDetails.swift
│   │
│   └── User
│       └── UserModel.swift
│
├── Storage
│   │
│   ├── CoreDataStack.swift
│   ├── PillsDataLocalStorage.swift
│   └── TransactionStorage.swift
│
├── Utilities
│   │
│   ├── AppColors.swift
│   ├── Extensions.swift
│   └── Logger.swift
│
└── Resources
├── Assets.xcassets
├── Icons
└── Localizable.strings

```

---

# Error Handling

The system includes safeguards for:

- Invalid barcode scans
- NDC mismatches
- Camera capture failures
- Network errors
- Counting inconsistencies

---

# Security & Compliance

To maintain pharmacy safety standards:

- Controlled drug workflows enforce verification
- NDC matching prevents incorrect dispensing
- Transaction records provide audit capability
- Vial images help maintain compliance



