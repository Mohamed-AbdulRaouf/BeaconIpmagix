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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let key = BeaconIpmagix.shared.getAppKey() {
            debugPrint("🔑 Current appKey: \(key)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

