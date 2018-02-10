//
//  BaseNavigationController.swift
//  newsclient
//
//  Created by rightmeow on 1/25/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    private func setupNavigationBar() {
        self.navigationBar.barStyle = .black
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = Color.specialYellow
        self.navigationBar.backgroundColor = Color.clear
        self.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "bg"), for: UIBarMetrics.default)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

}
