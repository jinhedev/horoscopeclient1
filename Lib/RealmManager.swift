//
//  RealmManager.swift
//  BitCoinClient
//
//  Created by rightmeow on 1/12/18.
//  Copyright © 2018 rightmeow. All rights reserved.
//

import Foundation
import RealmSwift

protocol PersistentContainerDelegate: NSObjectProtocol {
    func persistentContainer(_ manager: RealmManager, didErr error: Error)
    func didMigrateDatabase(_ manager: RealmManager)
    func didPurgeDatabase(_ manager: RealmManager)
}

extension PersistentContainerDelegate {
    func didMigrateDatabase(_ manager: RealmManager) {}
    func didPurgeDatabase(_ manager: RealmManager) {}
}

var defaultRealm: Realm!
var testRealm: Realm!

func setupRealm() {
    let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    let fileUrl = URL(fileURLWithPath: dir, isDirectory: true).appendingPathComponent("default.realm")
    let config = Realm.Configuration(fileURL: fileUrl, schemaVersion: 0, migrationBlock: nil, objectTypes: [])
    defaultRealm = try! Realm(configuration: config)
}

class RealmManager: NSObject {

    weak var delegate: PersistentContainerDelegate?

    func purgeDatabase() {
        do {
            try defaultRealm.write {
                defaultRealm.deleteAll()
            }
            delegate?.didPurgeDatabase(self)
        } catch let err {
            delegate?.persistentContainer(self, didErr: err)
        }
    }

    private func shouldMigrate() -> Bool {
        return false
    }

}


