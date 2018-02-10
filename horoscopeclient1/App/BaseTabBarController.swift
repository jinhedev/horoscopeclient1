//
//  BaseTabBarController.swift
//  newsclient
//
//  Created by rightmeow on 1/25/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    private func setupTabBar() {
        self.tabBar.isTranslucent = false
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabBar()
    }

}
