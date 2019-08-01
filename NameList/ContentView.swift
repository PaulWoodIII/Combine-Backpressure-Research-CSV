//
//  ContentView.swift
//  NameList
//
//  Created by Paul Wood on 7/31/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  
  @ObservedObject var provider = NameProvider()
  
  var body: some View {
    NavigationView {
      VStack {
        Text("Some Top Names from 1880").font(.title).lineLimit(nil)
        Text("Provided by Data.gov and Social Security records").font(.subheadline).lineLimit(nil)
        List(provider.displayNames) { name in
          HStack {
            VStack(alignment: .leading) {
              Text(name.name).font(.headline)
              Text("\(name.gender == "F" ? "👩" : "👨")").font(.caption)
            }
            Spacer()
            Text("\(name.count)")
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
