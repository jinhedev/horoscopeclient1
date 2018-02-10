//
//  ContainerViewTwoController.swift
//  horoscopeclient
//
//  Created by rightmeow on 2/1/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import UIKit

class ContainerViewTwoController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var selectedConstellation: Constellation?
    var arrayOfData = [StarModel]()
    var webServiceManager: WebServiceManager?

    private func setupUITableView() {
        self.tableView.register(UINib(nibName: ConstellationDetailsCell.nibName, bundle: nil), forCellReuseIdentifier: ConstellationDetailsCell.cell_id)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUITableView()
        self.setupUITableViewDataSource()
        self.setupUITableViewDelegate()
        self.setupWebServiceManagerDelegate()
        // initial actions
        if let star = self.selectedConstellation?.pingying {
            self.webServiceManager?.fetch(fromUrl: WebServiceConfiguration.baseUrl, parameters: ["showapi_appid" : WebServiceConfiguration.showapi_appid, "showapi_sign" : WebServiceConfiguration.showapi_sign, "star" : star, "needMonth" : "1"], headers: nil, type: WebServiceType.tests)
        }
    }

}

extension ContainerViewTwoController: WebServiceManagerDelegate {

    private func setupWebServiceManagerDelegate() {
        self.webServiceManager = WebServiceManager()
        self.webServiceManager!.delegate = self
    }

    func webService(_ manager: WebServiceManager, didErr error: Error, type: WebServiceType) {
        print(error.localizedDescription)
    }

    /// wrong handling of json passing
    func webService(_ manager: WebServiceManager, didFetch data: Any, type: WebServiceType) {
        if let json = data as? NSDictionary, let showapi_res_body = json["showapi_res_body"] as? NSDictionary {
            guard let month = showapi_res_body["month"] as? NSDictionary else { return }
            let month_advantage = month["month_advantage"] as? String
            let month_disadvantage = month["month_weakness"] as? String
            let love_txt = month["love_txt"] as? String
            let money_txt = month["money_txt"] as? String
            let work_txt = month["work_txt"] as? String
            let general_txt = month["general_txt"] as? String
            let month_advantage_model = StarModel(title: "本月优势", subtitle: month_advantage!)
            let month_disadvantage_model = StarModel(title: "本月弱势", subtitle: month_disadvantage!)
            let love_txt_model = StarModel(title: "爱情运势", subtitle: love_txt!)
            let money_txt_model = StarModel(title: "财富运势", subtitle: money_txt!)
            let work_txt_model = StarModel(title: "工作运势", subtitle: work_txt!)
            let general_txt_model = StarModel(title: "运势简评", subtitle: general_txt!)
            self.arrayOfData.append(general_txt_model)
            self.arrayOfData.append(month_advantage_model)
            self.arrayOfData.append(month_disadvantage_model)
            self.arrayOfData.append(love_txt_model)
            self.arrayOfData.append(money_txt_model)
            self.arrayOfData.append(work_txt_model)
            self.tableView.reloadData()
        }
    }

}

extension ContainerViewTwoController: UITableViewDelegate {

    private func setupUITableViewDelegate() {
        self.tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // do nothing
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

extension ContainerViewTwoController: UITableViewDataSource {

    private func setupUITableViewDataSource() {
        self.tableView.dataSource = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: ConstellationDetailsCell.cell_id, for: indexPath) as? ConstellationDetailsCell {
            cell.titleLabel.text = arrayOfData[indexPath.row].title
            cell.subtitleLabel.text = arrayOfData[indexPath.row].subtitle
            return cell
        } else {
            return BaseTableViewCell()
        }
    }

}
