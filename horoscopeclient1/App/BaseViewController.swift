//
//  BaseViewController.swift
//  newsclient
//
//  Created by rightmeow on 1/25/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: - API

    private func setupView() {
        self.view.backgroundColor = Color.clear
    }

    private func animateView(didAppear: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: { [weak self] in
            self?.view.alpha = didAppear ? 1.0 : 0.7
            }, completion: nil)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animateView(didAppear: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.animateView(didAppear: false)
    }

}
