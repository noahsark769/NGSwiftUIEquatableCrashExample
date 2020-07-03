//
//  ContentView.swift
//  NGSwiftUIEquatableCrashExample
//
//  Created by Noah Gilmore on 7/3/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import SwiftUI

enum Type {
    // If you remove the associated type here it works?
    case one(info: String)
    case two(info: String)
    case three(info: String)
    case four(info: String)
    case five(info: String)
    case six
    case seven(info: String)
    case eight(info: String)
    case nine(info: String)
    case ten(info: String)
    case eleven(info: String)
}

struct DetailView: View {
    let type: Type = .six
    let didTap: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                self.didTap()
            }, label: {
                Text("Tap here to crash")
            })
        }
    }
}
