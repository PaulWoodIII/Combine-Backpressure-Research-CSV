//
//  SyncImportToMainContext.swift
//  NameList
//
//  Created by Paul Wood on 8/2/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import CoreData

class SyncImportToMainContext {
  var dataProvider: NameDatabaseProvider
  init(dataProvider: NameDatabaseProvider) {
    self.dataProvider = dataProvider
    NotificationCenter.default.addObserver(
        self, selector: #selector(type(of: self).didFindRelevantTransactions(_:)),
        name: .didFindRelevantTransactions, object: nil)
  }
}

// MARK: - Handling didFindRelevantTransactions

extension SyncImportToMainContext {
    /**
     Handle didFindRelevantTransactions notification.
     */
    @objc
    func didFindRelevantTransactions(_ notification: Notification) {
        guard let relevantTransactions = notification.userInfo?["transactions"] as? [NSPersistentHistoryTransaction] else { preconditionFailure()
      }
      update(with: relevantTransactions)
    }
    
    // Reset and reload if the transaction count is high. When there are only a few transactions, merge the changes one by one.
    // Ten is an arbitrary choice. Adjust this number based on performance.
    private func update(with transactions: [NSPersistentHistoryTransaction]) {
        if transactions.count > 100 {
            print("###\(#function): Relevant transactions:\(transactions.count), reset and reload.")
            resetAndReload()
            return
        }
        
        transactions.forEach { transaction in
            guard let userInfo = transaction.objectIDNotification().userInfo else { return }
            let viewContext = dataProvider.persistentContainer.viewContext
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: userInfo, into: [viewContext])
        }
    }
    
    /**
     Reset the viewContext and reload the table view. Retain the selection and update detailViewController by calling didUpdatePost.
     */
    private func resetAndReload() {
        dataProvider.persistentContainer.viewContext.reset()
        do {
            try self.dataProvider.fetchedResultsController.performFetch()
        } catch {
            fatalError("###\(#function): Failed to performFetch: \(error)")
        }
    }
}
