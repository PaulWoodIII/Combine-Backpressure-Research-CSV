//
//  CoreData+Convenience.swift
//  NameList
//
//  Created by Paul Wood on 8/1/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Creating Contexts

let appTransactionAuthorName = "app"

/**
 A convenience method for creating background contexts that specify the app as their transaction author.
 */
extension NSPersistentContainer {
    func backgroundContext() -> NSManagedObjectContext {
        let context = newBackgroundContext()
        context.transactionAuthor = appTransactionAuthorName
        return context
    }
}

// MARK: - Saving Contexts

/**
 Contextual information for handling Core Data context save errors.
 */
enum ContextSaveContextualInfo: String {
    case addName = "adding a name"
    case deleteName = "deleting a post"
    case batchAddNames = "adding a batch of names"
    case addYear = "adding a year"
    case deleteYear = "deleting a year"
    case deduplicate = "deduplicating names"
}

extension NSManagedObjectContext {
    
    /**
     Handles save error by presenting an alert.
     */
    private func handleSavingError(_ error: Error, contextualInfo: ContextSaveContextualInfo) {
        log.error("Context saving error: \(error)")
        
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window,
                let viewController = window?.rootViewController else { return }
            
            let message = "Failed to save the context when \(contextualInfo.rawValue)."
            
            // Append message to existing alert if present
            if let currentAlert = viewController.presentedViewController as? UIAlertController {
                currentAlert.message = (currentAlert.message ?? "") + "\n\n\(message)"
                return
            }
            
            // Otherwise present a new alert
            let alert = UIAlertController(title: "Core Data Saving Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            viewController.present(alert, animated: true)
        }
    }
    
    /**
     Save a context, or handle the save error (for example, when there data inconsistency or low memory).
     */
    func save(with contextualInfo: ContextSaveContextualInfo) {
        guard hasChanges else { return }
        do {
            try save()
        } catch {
            handleSavingError(error, contextualInfo: contextualInfo)
        }
    }
}
