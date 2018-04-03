//
//  BiometricIDAuth.swift
//  TouchID
//
//  Created by Tatiana Magdalena on 17/03/18.
//  Copyright © 2018 Tatiana Magdalena. All rights reserved.
//

import Foundation
import LocalAuthentication

/// Handles Biometric ID authentication.
class BiometricIDAuth {

    // MARK: Private properties
    
    private let context = LAContext()
    private var policy: LAPolicy
    private var reason: String
    
    // MARK: Public properties
    
    var localizedCancelTitle: String? {
        didSet {
            context.localizedCancelTitle = localizedCancelTitle
        }
    }
    
    var localizedFallbackTitle: String? {
        didSet {
            context.localizedFallbackTitle = localizedFallbackTitle
        }
    }
    
    // MARK: - Initializers -
    
    init(reason: String, fallback: Fallback) {
        switch fallback {
        case .devicePasscode: policy = .deviceOwnerAuthentication
        case .appPassword: policy = .deviceOwnerAuthenticationWithBiometrics
        case .none: policy = .deviceOwnerAuthenticationWithBiometrics
        }
        self.reason = reason
    }
    
    // MARK: - Public API -
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(policy, error: nil)
    }
    
    func biometricType() -> BiometricType {
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .none: return .none
            case .touchID: return .touchID
            case .faceID: return .faceID
            }
        } else {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                return .touchID
            }
            return .none
        }
    }
    
    func authenticateUser(completion: @escaping (AuthenticationError?) -> Void) {
        guard canEvaluatePolicy() else {
            completion(.notAvailable)
            return
        }
        
        context.evaluatePolicy(policy,
                               localizedReason: reason) { success, evaluateError in
            if success {
                completion(nil)
            } else {
                let authError = self.transformToAuthenticationError(evaluateError: evaluateError)
                completion(authError)
            }
        }
    }
    
    // MARK: - Private methods -
    
    private func transformToAuthenticationError(evaluateError: Error?) -> AuthenticationError {
        if #available(iOS 11.0, *) {
            switch evaluateError {
            case LAError.authenticationFailed?:
                return (.authenticationFailed)
            case LAError.userCancel?:
                return (.userCancel)
            case LAError.userFallback?:
                return (.userFallback)
            case LAError.biometryNotAvailable?:
                return (.biometryNotAvailable)
            case LAError.biometryNotEnrolled?:
                return (.biometryNotEnrolled)
            case LAError.biometryLockout?:
                return (.biometryLockout)
            default:
                return (.generic)
            }
        } else {
            switch evaluateError {
            case LAError.authenticationFailed?:
                return (.authenticationFailed)
            case LAError.userCancel?:
                return (.userCancel)
            case LAError.userFallback?:
                return (.userFallback)
            case LAError.touchIDNotAvailable?:
                return (.biometryNotAvailable)
            case LAError.touchIDNotEnrolled?:
                return (.biometryNotEnrolled)
            case LAError.touchIDLockout?:
                return (.biometryLockout)
            default:
                return (.generic)
            }
        }
    }
}

// MARK: - Nested Types -

extension BiometricIDAuth {
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    /// Which fallback will be used if TouchID/FaceID is not available, the user presses cancel or the user misses biometry three times.
    ///
    /// - devicePasscode: Fallback to the device passcode.
    /// - appPassword: Fallback to a custom app password.
    /// - none: No fallback.
    enum Fallback {
        case devicePasscode
        case appPassword
        case none
    }
    
    /// Authentication domain error.
    enum AuthenticationError: Error {
        case notAvailable
        case authenticationFailed
        case userCancel
        case userFallback
        case biometryNotAvailable
        case biometryNotEnrolled
        case biometryLockout
        case generic
        
        private static var errorMessages: [AuthenticationError: String] = [
            .notAvailable: "Required authentication method is not available on this device.",
            .authenticationFailed: "There was a problem verifying your identity.",
            .userCancel: "You pressed cancel.",
            .userFallback: "You pressed password.",
            .biometryNotAvailable: "Face ID/Touch ID is not available.",
            .biometryNotEnrolled: "Face ID/Touch ID is not set up.",
            .biometryLockout: "Face ID/Touch ID is locked.",
            .generic: "Face ID/Touch ID may not be configured",
        ]
        
        var message: String {
            return AuthenticationError.errorMessages[self] ?? ""
        }
        
        static func setErrorMessage(_ message: String, authenticationError: AuthenticationError) {
            AuthenticationError.errorMessages[authenticationError] = message
        }
        
        static func setErrorMessages(_ messages: [AuthenticationError: String]) {
            for (error, message) in messages {
                setErrorMessage(message, authenticationError: error)
            }
        }
    }
}
