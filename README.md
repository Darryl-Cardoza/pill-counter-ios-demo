# MobRite Pill Counting Application — iOS

The **MobRite Pill Counting Application** is a professional iOS system designed to automate pharmaceutical pill counting workflows using camera-based detection, barcode scanning, and HL7 integration with pharmacy management systems.

The application enables pharmacists to perform **accurate pill counting, controlled drug verification, and transaction management** while maintaining secure communication with external healthcare infrastructure.

The system is built using **SwiftUI, MVVM architecture, and modular feature-based design** to ensure scalability, maintainability, and clear separation of concerns.

---

# System Overview

MobRite Pill Counter is part of the **MobRite pharmacy automation ecosystem**, designed to support:

* Automated pill counting workflows
* Prescription validation
* Controlled substance verification
* HL7 communication with pharmacy management systems
* Secure pharmaceutical transaction tracking

The system performs **on-device processing**, minimizing latency and ensuring reliability in pharmacy environments.

---

# Architecture

The application follows a **modular MVVM architecture** combined with a **clean separation of infrastructure, domain logic, and UI layers**.

```
Presentation Layer
│
├─ SwiftUI Views
├─ Feature Screens
└─ Reusable UI Components
        │
        ▼
ViewModel Layer
│
├─ Screen State Management
├─ UI Business Logic
└─ Feature Coordination
        │
        ▼
Repository Layer
│
├─ Data Aggregation
├─ API Communication
└─ Local Data Access
        │
        ▼
Data Sources
│
├─ Local Storage
├─ Secure Configuration
└─ External System Communication
        │
        ▼
Infrastructure Layer
│
├─ HL7 Messaging
├─ Network Services
├─ Security & Encryption
└─ Application Utilities
```

This structure ensures that:

* UI remains independent from business logic
* Features are isolated and maintainable
* Infrastructure concerns remain centralized

---

# Project Structure

```
PillCounter
│
├── Base
│   ├── AppLogoutManager
│   ├── BaseRepository
│   └── BaseView
│
├── Core
│   │
│   ├── Components
│   │   ├── Button
│   │   ├── Calendar
│   │   ├── Checkbox
│   │   ├── Confirmation
│   │   ├── ConfirmationDialogue
│   │   ├── InputField
│   │   ├── Loader
│   │   └── TextEditor
│   │
│   ├── Config
│   ├── Constants
│   │
│   ├── HL7
│   │   ├── Network
│   │   └── Service
│   │
│   └── Utils
│
├── Features
│   │
│   ├── Login
│   │
│   ├── Scanning
│   │   ├── LocalDataSource
│   │   ├── Model
│   │   │   └── ControlledDrug
│   │   └── ViewModel
│   │       ├── PillScanViewModel
│   │       └── CameraViewModel
│   │
│   └── User
│       ├── Model
│       │   ├── Request
│       │   └── Response
│       │
│       ├── Repository
│       │   ├── SettingsRepository
│       │   ├── UserLocalDataSource
│       │   └── UserRepository
│       │
│       ├── View
│       └── ViewModel
│           └── UserViewModel
│
├── Navigation
│   ├── Router
│   └── AppNavigation
│
├── Assets
├── Config
├── Localizable
│
├── PillCounterApp.swift
├── SecurityViolationView
│
├── Tests
│   ├── PillCounterTests
│   └── PillCounterUITests
```

---

# Core Modules

## Base Layer

The **Base module** provides shared abstractions used across the application.

Key responsibilities include:

* Common view abstractions
* Shared repository behavior
* Application logout management

This layer ensures consistent patterns across feature modules.

---

# Core Infrastructure

## Components

Reusable SwiftUI components used throughout the application interface.

Examples include:

* Button components
* Form inputs
* Confirmation dialogs
* Loaders
* UI utilities

These components ensure **consistent UI patterns and styling** across the system.

---

## Configuration

The configuration layer manages:

* Environment configuration
* Application constants
* Secure configuration files

Sensitive configuration values are encrypted and loaded securely at runtime.

---

## HL7 Integration

The HL7 module enables communication with **external pharmacy management systems**.

### Network Layer

Handles:

* HL7 transport communication
* Message delivery
* External system connectivity

### Service Layer

Responsible for:

* HL7 message construction
* Message parsing
* Processing inbound system messages

This module enables the application to integrate with **pharmacy and hospital systems using healthcare interoperability standards**.

---

# Feature Modules

Application functionality is organized using **feature-driven modules** to improve maintainability and scalability.

---

## Login

Handles authentication and session management.

Responsibilities include:

* User login flow
* Secure session initialization
* Authentication state management

---

## Scanning

The scanning module is responsible for **pill counting operations**.

Key responsibilities include:

* Camera lifecycle management
* Pill detection workflow
* Controlled drug validation
* Transaction creation

### Core Components

**ViewModels**

* `PillScanViewModel`
* `CameraViewModel`

These manage camera input, detection state, and transaction logic.

**Models**

* Controlled drug models
* Scanning data models

---

## User Module

The User module manages user-related data and application settings.

### Data Models

* API request models
* API response models

### Repositories

* `UserRepository`
* `SettingsRepository`
* `UserLocalDataSource`

These handle both **remote and local data sources**.

### ViewModels

* `UserViewModel`

Responsible for user state and profile logic.

---

# Navigation

Navigation is handled through a centralized routing system.

```
Navigation
├── Router
└── AppNavigation
```

Responsibilities include:

* Application routing
* Screen flow control
* Navigation state management

This approach prevents navigation logic from leaking into feature modules.

---

# Security

Security is a critical component of the system due to healthcare and pharmaceutical requirements.

Security features include:

* Encrypted configuration files
* Secure token storage
* Session management
* Runtime security validation

The `SecurityViolationView` is responsible for handling potential security issues detected within the application.

---

# Testing

The project includes both **unit tests and UI tests**.

```
PillCounterTests
PillCounterUITests
```

Test coverage focuses on:

* ViewModel logic
* Business rules
* Navigation behavior
* UI interaction flows

---

# Organization

Developed by **Rite Technologies**

MobRite products focus on:

* Pharmacy automation
* Pill counting systems
* Healthcare system integrations
* HL7-based interoperability solutions
