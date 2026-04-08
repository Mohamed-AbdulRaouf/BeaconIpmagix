//
//  LoginQNBViewController.swift
//  BeaconIpmagix
//
//  Created by Raouf on 29/03/2026.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import BeaconIpmagix

class LoginQNBViewController: UIViewController {

    // QNB Navy Blue Color
    let qnbDarkBlue = UIColor(red: 0/255, green: 32/255, blue: 75/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic-qnb-logo")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.widthAnchor.constraint(equalToConstant: 208).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        return imageView
    }()

    // 3. Username Field
    var usernameLabel = UILabel()
    var usernameField = UITextField()

    // 4. Password Field
    var passwordLabel = UILabel()
    var passwordField = UITextField()

    private func setupUI() {
        // 1. Logo and App Name
//        let logoLabel = UILabel()
//        logoLabel.text = "QNB"
//        logoLabel.font = .systemFont(ofSize: 48, weight: .bold)
//        logoLabel.textColor = qnbDarkBlue
        
        // 2. Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Login to your account"
        subtitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        // 3. Username Field
         usernameLabel = createInputLabel(text: "Username")
         usernameField = createTextField(placeholder: "Enter your username")

        // 4. Password Field
         passwordLabel = createInputLabel(text: "Password")
         passwordField = createTextField(placeholder: "Enter your password", isSecure: true)


        // 5. Continue Button
        let continueButton = UIButton(type: .system)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.backgroundColor = qnbDarkBlue
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        continueButton.layer.cornerRadius = 8
        continueButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)


        let headerStack = UIStackView(arrangedSubviews: [logoImage, UILabel()])
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .leading
        // Layout using StackView
        let stackView = UIStackView(arrangedSubviews: [
            headerStack,
            subtitleLabel,
            usernameLabel, usernameField,
            passwordLabel, passwordField,
            continueButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.setCustomSpacing(40, after: headerStack)
        stackView.setCustomSpacing(30, after: subtitleLabel)
        stackView.setCustomSpacing(30, after: passwordField)
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            usernameField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            continueButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    // MARK: - Helpers
    private func createInputLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.backgroundColor = .white
        label.textColor = .black
        return label
    }
    
    private func createTextField(placeholder: String, isSecure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.black]
        )
        tf.isSecureTextEntry = isSecure
        tf.borderStyle = .roundedRect
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 8
        tf.textColor = .black
        return tf
    }

    // MARK: - Actions
    @objc private func handleLogin() {
        guard let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            debugPrint("⚠️ Missing credentials")
            return
        }

        let requestBody = LoginRequest(userName: username, password: password)

        guard let url = URL(string: EndpointsBeacons.userLogin) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(BaseBeaconApi.apiKey, forHTTPHeaderField: "X-API-KEY")

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            debugPrint("❌ Encoding error:", error)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                debugPrint("❌ Request error:", error)
                return
            }

            guard let data = data else { return }

            do {
                let result = try JSONDecoder().decode(LoginResponseModel.self, from: data)

                guard result.success else {
                    debugPrint("❌ Login failed: \(result.message)")
                    return
                }

                guard let userData = result.data else {
                    debugPrint("❌ Data is nil")
                    return
                }

                // Save token and displayName
                UserDefaults.standard.set(userData.token, forKey: "authToken")
                UserDefaults.standard.set(userData.displayName, forKey: "displayName")
                UserDefaults.standard.set(userData.beacons, forKey: "beacons")

                // Convert beacon UUIDs to RegionBeaconModel list
                let beaconsList: [RegionBeaconModel] = userData.beacons.map { uuid in
                    return RegionBeaconModel(
                        uuid: uuid,
                        beaconMac: uuid,
                        orgID: "",
                        groupID: "",
                        categoryID: "",
                        name: uuid,
                        placeID: "",
                        notificationID: ""
                    )
                }

                // Example usage: print or pass to SDK
                debugPrint("📡 Beacons List: \(beaconsList)")

                DispatchQueue.main.async {
                    debugPrint("✅ Login success: \(userData.displayName)")
                    BeaconIpmagix.shared.setBeaconsListAndStartScanning(beaconsList)
                    self.navigateToHomePage()
                }

            } catch {
                debugPrint("Error decoding login response: \(error)")
            }
        }.resume()
    }

    private func navigateToHomePage() {
        let homeVC = HomeQNBViewController()
        homeVC.modalPresentationStyle = .fullScreen
        self.present(homeVC, animated: true, completion: nil)
    }

}
