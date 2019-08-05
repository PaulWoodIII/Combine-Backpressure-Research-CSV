//
//  PreviewAppEnvironment.swift
//  NameList
//
//  Created by Paul Wood on 8/5/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftyBeaver

class PreviewApplicationEnvironment {
  static let shared = ApplicationEnvironment()
  lazy var coreDataStack: CoreDataStack = { return CoreDataStack(configuration: .preview) }()
  lazy var sharedNameProvider = NameDatabaseProvider(with: coreDataStack.persistentContainer, fetchedResultsControllerDelegate: nil)
  lazy var sharedYearProvider = YearDatabaseProvider(with: coreDataStack.persistentContainer, fetchedResultsControllerDelegate: nil)
  lazy var importer = NameDatabaseImporter(provider: sharedNameProvider, yearProvider: sharedYearProvider)
}


struct PreviewAppEnvironment: ViewModifier {
  
  func body(content: Content) -> some View {
    content
      //.environmentObject(ApplicationEnvironment.shared.coreDataStack.persistentContainer.viewContext)
      .environmentObject(ApplicationEnvironment.shared.coreDataStack)
      .environmentObject(ApplicationEnvironment.shared.sharedNameProvider)
      .environmentObject(ApplicationEnvironment.shared.sharedYearProvider)
      .environmentObject(ApplicationEnvironment.shared.importer)
      .environment(\.managedObjectContext, ApplicationEnvironment.shared.coreDataStack.persistentContainer.viewContext)
  }
}

extension View {
  func previewAppEnvironment() -> some View {
    ModifiedContent(content: self, modifier: PreviewAppEnvironment())
  }
}
