//
//  ContentView.swift
//  NGSwiftUIEquatableCrashExample
//
//  Created by Noah Gilmore on 7/3/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import SwiftUI
import CoreImage

struct FilterParameterSwiftUIView: View {
    let parameter: FilterParameterInfo

    var body: some View {
        Text("\(self.parameter.name)")
    }
}

struct FilterDetailContentView: View {
    let filterInfo: FilterInfo
    let didTapTryIt: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(filterInfo.parameters, id: \.name) { parameter in
                    FilterParameterSwiftUIView(parameter: parameter)
                }
            }

            Button(action: {
                self.didTapTryIt()
            }, label: {
                Text("Try It!")
            })
        }
    }
}

enum FilterParameterType {
    // If you remove the associated type here it works?
    case unspecifiedNumber(info: String)
    case angle(info: String)
    case boolean(info: String)
    case count(info: String)
    case data(info: String)
    case barcode
    case color(info: String)
    case opaqueColor(info: String)
    case transform(info: String)
    case unspecifiedObject(info: String)
    case string(info: String)
}

struct FilterParameterInfo {
    let name: String = "hey"
    let type: FilterParameterType = .barcode
}

struct FilterInfo {
    let name: String = "Name"
    let parameters = [FilterParameterInfo()]
}

struct ContentView: View {
    let value: FilterInfo
    let didTap: () -> Void

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        VStack {
            Text("Current value: \(value.name) (\(horizontalSizeClass == .compact ? "Compact" : "Not Compact"))")
            Button(action: {
                self.didTap()
            }, label: {
                Text("Tap here")
            })
        }
    }
}
