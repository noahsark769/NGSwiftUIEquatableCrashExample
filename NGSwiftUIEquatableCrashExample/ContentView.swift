//
//  ContentView.swift
//  NGSwiftUIEquatableCrashExample
//
//  Created by Noah Gilmore on 7/3/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import SwiftUI
import CoreImage

struct ParameterView: View {
    let parameter: Parameter

    var body: some View {
        Text("Text here")
    }
}

struct DetailView: View {
    let info: Info
    let didTapTryIt: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            ParameterView(parameter: info.parameters.first!)

            Button(action: {
                self.didTapTryIt()
            }, label: {
                Text("Try It!")
            })
        }
    }
}

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

struct Parameter {
    let type: Type = .six
}

struct Info {
    let parameters = [Parameter()]
}

struct ContentView: View {
    let value: Info
    let didTap: () -> Void

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        VStack {
            Text("Current value: (\(horizontalSizeClass == .compact ? "Compact" : "Not Compact"))")
            Button(action: {
                self.didTap()
            }, label: {
                Text("Tap here")
            })
        }
    }
}
