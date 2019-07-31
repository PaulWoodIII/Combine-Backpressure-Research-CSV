//
//  ContentView.swift
//  NameList
//
//  Created by Paul Wood on 7/31/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  
  let names: [NameType] = {
    var names: [NameType]!
    _ = NameImporter().importFrom(file: .test)
      .collect()
      .replaceError(with: [])
      .sink{ n in
      names = n
    }
    return names
  }()
  
    var body: some View {
      NavigationView {
        VStack {
          Text("Some Top Names from 1880").font(.title).lineLimit(nil)
          Text("Provided by Data.gov and Social Security records").font(.subheadline).lineLimit(nil)
          List(names) { name in
            HStack{
              Text("Name: \(name.name)")
              Text("Gender: \(name.gender)")
              Text("Count: \(name.count)")
            }
          }
        }
      }
    }
}

extension NameType: Identifiable {
  var id: String {
    return name
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
