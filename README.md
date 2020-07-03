# NGSwiftUIEquatableCrashExample (FB7847416)
Non-equatable enums with ten or more cases with associated values cause crash when set as a SwiftUI state variable

If an enum without Equatable conformance and with ten or more cases where each has an associated value is part of a State property in a SwiftUI view, and a callback triggers that state to change to a value which is equivalent, the app crashes.

Steps to reproduce:

1. Clone the code at https://github.com/noahsark769/NGSwiftUIEquatableCrashExample
2. Run the app (any iOS simulator should work, but I tested iPhone 11 on iOS 13.5 and 14.0 beta 1
3. Tap the button twice

Expected: Nothing happens, since the state resets itself to an equivalent value
Actual: App crashes

Notes:
- Reproducible on Xcode 11 and 12 beta 1, iOS 13 and 14 beta 1
- Making the enum Equatable resolves the issue
- Commenting out one of the enum cases resolves the issue
- Commenting out the associated value of one of the enum cases resolves the issue
- It seems that SwiftUI is doing something under the hood to compare the enum values even though the enum is not Equatable, and can't handle more than 10 cases in this case. If this is the case, it would be ideal to print some kind of warning or raise an exception instead of crashing.
- A full reproduction case can be triggered with the "New Project" template for a SwiftUI iOS app in Xcode 11 where the following is the ContentView definition:

```
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

struct ContentView: View {
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
```
