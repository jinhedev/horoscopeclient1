//
//  FortunesViewController.swift
//  horoscopeclient1
//
//  Created by OD2 on 19/02/2018.
//  Copyright © 2018 rightmeow. All rights reserved.
//

import UIKit
import Amplitude

class FortunesViewController: BaseViewController {
    
    // MARK: - API
    
    var webServiceManager: WebServiceManager?
    static let storyboard_id = String(describing: FortunesViewController.self)
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var giftTitleLabel: UILabel!
    @IBOutlet weak var giftImageView: UIImageView!
    @IBOutlet weak var fortuneTitleLabel: UILabel!
    @IBOutlet weak var fortuneBodyLabel: UILabel!
    @IBOutlet weak var luckyColorLabel: UILabel!
    @IBOutlet weak var lucktNumberLable: UILabel!
    @IBOutlet weak var lucky_num: UILabel!
    
    private func setupView() {
        self.view.backgroundColor = Color.specialYellow
        self.giftTitleLabel.isHidden = true
        self.giftImageView.isHidden = true
        self.fortuneTitleLabel.isHidden = true
        self.fortuneBodyLabel.isHidden = true
        self.luckyColorLabel.isHidden = true
        self.lucktNumberLable.isHidden = true
        self.lucky_num.isHidden = true
    }
    
    private func updateView() {
        self.giftImageView.isHidden = shouldDeliverGift() ? false : true
        self.giftTitleLabel.isHidden = shouldDeliverGift() ? false : true
        self.fortuneTitleLabel.isHidden = shouldDeliverGift() ? true : false
        self.fortuneBodyLabel.isHidden = shouldDeliverGift() ? true : false
        self.luckyColorLabel.isHidden = shouldDeliverGift() ? true : false
        self.lucktNumberLable.isHidden = shouldDeliverGift() ? true : false
        self.lucky_num.isHidden = shouldDeliverGift() ? true : false
    }
    
    private func showFortuneTitleLabelAndFortuneBodyLabel() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1.0, options: [.curveEaseInOut], animations: {
            self.fortuneBodyLabel.isHidden = false
            self.fortuneTitleLabel.isHidden = false
        }, completion: nil)
    }
    
    private func setupGiftImageView() {
        giftImageView.isUserInteractionEnabled = true
        let gestureRecogniszer = UITapGestureRecognizer(target: self, action: #selector(hideGift))
        giftImageView.addGestureRecognizer(gestureRecogniszer)
    }
    
    @objc func showGift() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1.0, options: [.curveEaseInOut], animations: {
            self.giftImageView.transform = CGAffineTransform.identity
            self.giftTitleLabel.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc func hideGift() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1.0, options: [.curveEaseInOut], animations: {
            self.giftImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.giftTitleLabel.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { (completed) in
            self.setGiftDeliveryDate()
            self.showFortuneTitleLabelAndFortuneBodyLabel()
            self.luckyColorLabel.isHidden = false
            self.lucky_num.isHidden = false
            self.lucktNumberLable.isHidden = false
        }
    }
    
    func setGiftDeliveryDate() {
        let today = Date()
        UserDefaults.standard.set(today, forKey: kGiftDeliveryDate)
    }
    
    func giftDeliveryDate() -> Date? {
        if let value = UserDefaults.standard.value(forKey: kGiftDeliveryDate) as? Date {
            return value
        } else {
            return nil
        }
    }
    
    func shouldDeliverGift() -> Bool {
        if let timeIntervalInHourForStoredGiftDeliveryDate = giftDeliveryDate()?.toRelativeDay() {
            if timeIntervalInHourForStoredGiftDeliveryDate > 0 {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    private func setupUINavigationBar() {
        if let navigationController = self.navigationController as? BaseNavigationController {
            navigationController.navigationBar.barStyle = .black
            navigationController.navigationBar.isTranslucent = false
            navigationController.navigationBar.barTintColor = Color.specialYellow
            navigationController.navigationBar.backgroundColor = Color.clear
            navigationController.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "bg"), for: UIBarMetrics.default)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupGiftImageView()
        self.setupWebServiceManagerDelegate()
        // initial actions
        self.webServiceManager?.fetch(fromUrl: WebServiceConfiguration.baseUrl, parameters: ["showapi_appid" : WebServiceConfiguration.showapi_appid, "showapi_sign" : WebServiceConfiguration.showapi_sign, "star" : "shizi"], headers: nil, type: WebServiceType.tests)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupUINavigationBar()
        self.updateView()
    }
    
}

extension FortunesViewController: WebServiceManagerDelegate {
    
    private func setupWebServiceManagerDelegate() {
        self.webServiceManager = WebServiceManager()
        self.webServiceManager!.delegate = self
    }
    
    func webService(_ manager: WebServiceManager, didErr error: Error, type: WebServiceType) {
        print(error.localizedDescription)
        Amplitude.instance().logEvent("\(error.localizedDescription)")
    }
    
    func webService(_ manager: WebServiceManager, didFetch data: Any, type: WebServiceType) {
        print(data)
        if let json = data as? NSDictionary, let showapi_res_body = json["showapi_res_body"] as? NSDictionary {
            guard let day = showapi_res_body["day"] as? NSDictionary else { return }
            let luckyColor = day["lucky_color"] as? String
            let lucyNumber = day["lucky_num"] as? String
            self.fortuneBodyLabel.text = luckyColor
            self.lucky_num.text = lucyNumber
        }
    }
    
}
