//
//  ContentView.swift
//  NameList
//
//  Created by Paul Wood on 7/31/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  
  @EnvironmentObject var coreDataStack: CoreDataStack
  
  var body: some View {
    VStack {
      WrappedTableView(coreDataStack: coreDataStack)
    }
//    .navigationTitle("Name for year")
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().appEnvironment()
  }
}
#endif
