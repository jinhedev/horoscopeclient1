//
//  SignsViewController.swift
//  horoscopeclient
//
//  Created by rightmeow on 1/30/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import UIKit
import Amplitude

class ConstellationsViewController: BaseViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - API

    var constellations: [Constellation] = [
        Constellation(image_name: "aquarius", name: "水瓶座", pingying: "shuiping"),
        Constellation(image_name: "aries", name: "白羊座", pingying: "baiyang"),
        Constellation(image_name: "cancer", name: "巨蟹座", pingying: "juxie"),
        Constellation(image_name: "capricorn", name: "摩羯座", pingying: "mojie"),
        Constellation(image_name: "gemini", name: "双子座", pingying: "shuangzi"),
        Constellation(image_name: "leo", name: "狮子座", pingying: "shizi"),
        Constellation(image_name: "libra", name: "天秤座", pingying: "tiancheng"),
        Constellation(image_name: "pisces", name: "双鱼座", pingying: "shuangyu"),
        Constellation(image_name: "sagittarius", name: "射手座", pingying: "sheshou"),
        Constellation(image_name: "scorpio", name: "天蠍座", pingying: "tianxie"),
        Constellation(image_name: "taurus", name: "金牛座", pingying: "jinniu"),
        Constellation(image_name: "virgo", name: "處女座", pingying: "chunv")
    ]
    var webServiceManager: WebServiceManager?
    let collectionViewMargin: CGFloat = 32
    private let screenWidth = UIScreen.main.bounds.width
    static let storyboard_id = String(describing: ConstellationsViewController.self)
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUICollectionView()
        self.setupUICollectionViewDelegate()
        self.setupUICollectionViewDataSource()
        self.setupUICollectionViewDelegateFlowLayout()
        // initial actions
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let selectedIndex = self.collectionView.indexPathsForSelectedItems?.first {
            let selectedConstellation = self.constellations[selectedIndex.item]
            if segue.identifier == Segue.ConstellationsViewControllerToDetailsViewController {
                if let destinationViewController = segue.destination as? DetailsViewController {
                    destinationViewController.selectedConstellation = selectedConstellation
                }
            }
        }
    }

    // MAKR: - UICollectionView

    private func setupUICollectionView() {
        self.collectionView.contentInset = UIEdgeInsets(top: collectionViewMargin, left: collectionViewMargin, bottom: collectionViewMargin, right: collectionViewMargin)
        self.collectionView.backgroundColor = Color.specialYellow
    }

    // MARK: - UICollectionViewDelegate

    private func setupUICollectionViewDelegate() {
        self.collectionView.delegate = self
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segue.ConstellationsViewControllerToDetailsViewController, sender: self)
    }

    // MARK: - UICollectionViewDataSource

    private func setupUICollectionViewDataSource() {
        self.collectionView.dataSource = self
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.constellations.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ConstellationCell.cell_id, for: indexPath) as? ConstellationCell {
            cell.constellation = self.constellations[indexPath.item]
            return cell
        } else {
            return BaseCollectionViewCell()
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    private func setupUICollectionViewDelegateFlowLayout() {
        self.collectionViewFlowLayout.scrollDirection = .vertical
        self.collectionViewFlowLayout.minimumInteritemSpacing = 32
        self.collectionViewFlowLayout.minimumLineSpacing = collectionViewMargin
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width / 2) - 32 - 16
        let cellHeight = cellWidth + 32
        return CGSize(width: cellWidth, height: cellHeight)
    }

}
