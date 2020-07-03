//
//  ContentView.swift
//  NGSwiftUIEquatableCrashExample
//
//  Created by Noah Gilmore on 7/3/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import SwiftUI

// Note: Things that resolve the crash in this project:
// 1. removing an enum case
// 2. removing an associated value from an enum case
// 3. adding an Equtable conformance to the enum

enum Type {
    case one(info: String)
    case two(info: String)
    case three(info: String)
    case four(info: String)
    case five(info: String)
    case six(info: String)
    case seven(info: String)
    case eight(info: String)
    case nine(info: String)
    case ten(info: String)
}

struct DetailView: View {
    @State var type: Type = .one(info: "one")

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                self.type = .one(info: "one")
            }, label: {
                Text("Tap here to crash")
            })
        }
    }
}
