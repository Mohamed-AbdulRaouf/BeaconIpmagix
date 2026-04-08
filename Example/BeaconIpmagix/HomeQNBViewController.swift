//
//  HomeQNBViewController.swift
//  BeaconIpmagix
//
//  Created by Raouf on 29/03/2026.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import Combine
import BeaconIpmagix

class HomeQNBViewController: UIViewController {
    // MARK: - Properties
    private let textView = UITextView()
    private var cancellables = Set<AnyCancellable>()

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

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.text = "Welcome \(UserDefaults.standard.string(forKey: "displayName") ?? "User")"
        label.numberOfLines = 0
        return label
    }()

    private let logoutButton: UIButton = {
        let btn = UIButton(type: .custom)

        // Title
        btn.setTitle("  Logout", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.titleLabel?.addCharacterSpacing(kernValue: 0.5)

        // Icon
        let icon = UIImage(systemName: "rectangle.portrait.and.arrow.right")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.semanticContentAttribute = .forceLeftToRight
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        btn.contentEdgeInsets = UIEdgeInsets(top: 14, left: 32, bottom: 14, right: 32)

        // Background color
        let crimson = UIColor(red: 0.91, green: 0.25, blue: 0.25, alpha: 1.0)
        btn.backgroundColor = crimson

        // Capsule shape — set after layout, or use a fixed height
        btn.layer.cornerRadius = 25
        btn.layer.masksToBounds = false

        // Shadow
        btn.layer.shadowColor = UIColor(red: 0.91, green: 0.25, blue: 0.25, alpha: 0.45).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 12
        btn.layer.shadowOpacity = 1

        // Press interactions
        btn.addTarget(btn, action: #selector(UIButton.didTouchDown), for: [.touchDown, .touchDragEnter])
        btn.addTarget(btn, action: #selector(UIButton.didTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])

        return btn
    }()

    private let toggleLogsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Hide Logs", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .darkGray
        btn.layer.cornerRadius = 12
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindLogs()
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        toggleLogsButton.addTarget(self, action: #selector(toggleLogsVisibility), for: .touchUpInside)
        loadBeaconsFromCacheAndStart()
    }

    private func setupUI() {
        textView.frame = view.bounds
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.isEditable = false


        let headerStack = UIStackView(arrangedSubviews: [welcomeLabel, UIView(), logoImage, logoutButton, toggleLogsButton, textView])
        headerStack.axis = .vertical
        headerStack.spacing = 36
        headerStack.alignment = .fill
        // Layout using StackView
        view.addSubview(headerStack)
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])
    }

    @objc private func toggleLogsVisibility() {
        UIView.animate(withDuration: 0.25) {
            self.textView.isHidden.toggle()
        }
        let isHidden = textView.isHidden
        toggleLogsButton.setTitle(isHidden ? "Show Logs" : "Hide Logs", for: .normal)
    }

    private func bindLogs() {
        BeaconLogger.shared.$logs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] logs in
                DispatchQueue.main.async {
                    self?.textView.text = logs.joined(separator: "\n")
                }
                // auto scroll to bottom
                let range = NSRange(location: logs.joined(separator: "\n").count - 1, length: 1)
                self?.textView.scrollRangeToVisible(range)
            }
            .store(in: &cancellables)
    }


    private func loadBeaconsFromCacheAndStart() {
        guard let savedBeacons = UserDefaults.standard.stringArray(forKey: "beacons") else {
            debugPrint("⚠️ No cached beacons found")
            return
        }

        let beaconsList: [RegionBeaconModel] = savedBeacons.compactMap { dict in
            return RegionBeaconModel(
                uuid: dict,
                beaconMac: dict,
                orgID: dict ,
                groupID: dict ,
                categoryID: dict,
                name: dict,
                placeID: dict ,
                notificationID: dict
            )
        }

        if !beaconsList.isEmpty {
            debugPrint("✅ Loaded cached beacons: \(beaconsList.count)")
            BeaconIpmagix.shared.setBeaconsListAndStartScanning(beaconsList)
        } else {
            debugPrint("⚠️ Failed to map cached beacons")
        }
    }

    @objc private func handleLogout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "displayName")
        UserDefaults.standard.removeObject(forKey: "beacons")
        let vc = LoginQNBViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
