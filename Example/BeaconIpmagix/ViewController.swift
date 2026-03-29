//
//  ViewController.swift
//  BeaconIpmagix
//
//  Created by mohamed.a.raouf@icloud.com on 03/24/2026.
//  Copyright (c) 2026 mohamed.a.raouf@icloud.com. All rights reserved.
//

import UIKit
import BeaconIpmagix

class ViewController: UIViewController {
    // MARK: - Properties
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        return imageView
    }()

    private let usernameField: UITextField = {
        let tf = UITextField()

        // Content type
        tf.textContentType = .username
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no

        // Typography
        tf.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tf.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.18, alpha: 1.0)
        tf.tintColor = UIColor(red: 0.27, green: 0.51, blue: 0.98, alpha: 1.0)

        // Placeholder
        tf.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [
                .foregroundColor: UIColor(red: 0.65, green: 0.65, blue: 0.72, alpha: 1.0),
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )

        // Default text
        tf.text = "raouf"

        // Background & border
        tf.borderStyle = .none
        tf.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
        tf.layer.cornerRadius = 14
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1.5
        tf.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.93, alpha: 1.0).cgColor

        // Left icon
        let personIcon = UIImageView(image: UIImage(systemName: "person.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)))
        personIcon.tintColor = UIColor(red: 0.27, green: 0.51, blue: 0.98, alpha: 1.0)
        personIcon.contentMode = .scaleAspectFit
        personIcon.frame = CGRect(x: 0, y: 0, width: 40, height: 20)

        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        leftContainer.addSubview(personIcon)
        tf.leftView = leftContainer
        tf.leftViewMode = .always

        // Right clear button container
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(
            UIImage(systemName: "xmark.circle.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)),
            for: .normal
        )
        clearButton.tintColor = UIColor(red: 0.65, green: 0.65, blue: 0.72, alpha: 1.0)
        clearButton.frame = CGRect(x: 0, y: 0, width: 44, height: 20)
        clearButton.addTarget(tf, action: #selector(UITextField.clearText), for: .touchUpInside)

        let rightContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        rightContainer.addSubview(clearButton)
        tf.rightView = rightContainer
        tf.rightViewMode = .whileEditing

        // Height
        tf.heightAnchor.constraint(equalToConstant: 54).isActive = true

        return tf
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()

        // Secure entry
        tf.isSecureTextEntry = true
        tf.textContentType = .password

        // Typography
        tf.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tf.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.18, alpha: 1.0)
        tf.tintColor = UIColor(red: 0.27, green: 0.51, blue: 0.98, alpha: 1.0)

        // Placeholder
        tf.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [
                .foregroundColor: UIColor(red: 0.65, green: 0.65, blue: 0.72, alpha: 1.0),
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )

        // Default text
        tf.text = "111111"

        // Background & border
        tf.borderStyle = .none
        tf.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
        tf.layer.cornerRadius = 14
        tf.layer.masksToBounds = true
        tf.layer.borderWidth = 1.5
        tf.layer.borderColor = UIColor(red: 0.88, green: 0.88, blue: 0.93, alpha: 1.0).cgColor

        // Left icon padding
        let lockIcon = UIImageView(image: UIImage(systemName: "lock.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)))
        lockIcon.tintColor = UIColor(red: 0.27, green: 0.51, blue: 0.98, alpha: 1.0)
        lockIcon.contentMode = .scaleAspectFit
        lockIcon.frame = CGRect(x: 0, y: 0, width: 40, height: 20)

        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        leftContainer.addSubview(lockIcon)
        tf.leftView = leftContainer
        tf.leftViewMode = .always

        // Right eye toggle button
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(
            UIImage(systemName: "eye.slash.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)),
            for: .normal
        )
        eyeButton.setImage(
            UIImage(systemName: "eye.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)),
            for: .selected
        )
        eyeButton.tintColor = UIColor(red: 0.65, green: 0.65, blue: 0.72, alpha: 1.0)
        eyeButton.frame = CGRect(x: 0, y: 0, width: 44, height: 20)
        eyeButton.addTarget(tf, action: #selector(UITextField.toggleSecureEntry(_:)), for: .touchUpInside)

        let rightContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        rightContainer.addSubview(eyeButton)
        tf.rightView = rightContainer
        tf.rightViewMode = .always

        // Height via auto layout
        tf.heightAnchor.constraint(equalToConstant: 54).isActive = true

        return tf
    }()

    private let loginButton: UIButton = {
        let btn = UIButton(type: .custom)

        // Title
        btn.setTitle("  Login", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        // Icon
        let icon = UIImage(systemName: "arrow.right.circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.semanticContentAttribute = .forceLeftToRight
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        btn.contentEdgeInsets = UIEdgeInsets(top: 14, left: 32, bottom: 14, right: 32)

        let crimson = UIColor(red: 0.27, green: 0.51, blue: 0.98, alpha: 1.0) // Royal blue
        btn.backgroundColor = crimson

        // Capsule shape
        btn.layer.cornerRadius = 25
        btn.layer.masksToBounds = false

        // Shadow
        btn.layer.shadowColor = UIColor(red: 0.27, green: 0.51, blue: 0.98, alpha: 0.45).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.shadowRadius = 14
        btn.layer.shadowOpacity = 1

        // Press interactions
        btn.addTarget(btn, action: #selector(UIButton.didTouchDown), for: [.touchDown, .touchDragEnter])
        btn.addTarget(btn, action: #selector(UIButton.didTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])

        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        usernameField.addFocusObservers()
        passwordField.addFocusObservers() // keeps both fields in sync
        if let key = BeaconIpmagix.shared.getAppKey() {
            debugPrint("🔑 Current appKey: \(key)")
        }
        setupUI()
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
    }

    private func setupUI() {
        view.backgroundColor = .white

        let stack = UIStackView(arrangedSubviews: [imageView, usernameField, passwordField, loginButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func navigateToHomePage() {
        let homeVC = HomePageViewController()
        homeVC.modalPresentationStyle = .fullScreen
        self.present(homeVC, animated: true, completion: nil)
    }
}
