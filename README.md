# Biometric Identification
🔓 A helper to handle TouchID👆🏽 / FaceID👩🏽

## Installation

### Manually

Copy `BiometricIDAuth.swift` into your project.

## Usage

The simplest way to use it is by creating a `BiometricIDAuth` instance and calling the `authenticate` method on it.

```Swift
// Initialize it with a reason to be using the Biometric Identification and a fallback type
let biometricAuth = BiometricIDAuth(reason: "Some reason to be using Biometric Authentication",
                                    fallback: .devicePasscode)

// Ask for authentication based on fallback type
biometricAuth.authenticate { authError in
  if let error = authError {
    // handle error
  } else {
    // handle successful authentication
  }
}

```
