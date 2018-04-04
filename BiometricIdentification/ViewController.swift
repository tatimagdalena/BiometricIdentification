//
//  ViewController.swift
//  TouchID
//
//  Created by Tatiana Magdalena on 17/03/18.
//  Copyright © 2018 Tatiana Magdalena. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var authButton: UIButton!
    var biometricAuth: BiometricIDAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize with a reason to be using the Biometric Identification and a fallback type
        biometricAuth = BiometricIDAuth(reason: "Some reason to be using Biometric Authentication",
                                        fallback: .devicePasscode)
        
        biometricAuth.localizedFallbackTitle = "Enter device passcode"
        biometricAuth.localizedCancelTitle = "Stop this"
        
        // Only allows to try authentication if it is available
        authButton.isHidden = !biometricAuth.canEvaluatePolicy()
        
        // Change one error message
        BiometricIDAuth.AuthenticationError.setErrorMessage("Some error message when user presses cancel", authenticationError: .userCancel)
        
        // Change more than one error message at once
        let errorMessages: [BiometricIDAuth.AuthenticationError: String] = [
            .authenticationFailed: "Some reason for failure",
            .biometryNotEnrolled: "Some reason if biometry is not enrolled",
        ]
        BiometricIDAuth.AuthenticationError.setErrorMessages(errorMessages)
    }
    
    @IBAction func authenticate(_ sender: UIButton) {
        // Ask for authentication based on fallback type
        biometricAuth.authenticate { [weak self] authError in
            if let error = authError {
                DispatchQueue.main.async {
                    self?.showAlert(error: error)
                }
            } else {
                print("Handle successfull authentication")
            }
        }
    }
    
    func showAlert(error: BiometricIDAuth.AuthenticationError) {
        let alertView = UIAlertController(title: "Error",
                                          message: error.message,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Darn!", style: .default)
        alertView.addAction(okAction)
        present(alertView, animated: true)
    }
}
