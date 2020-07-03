//
//  ContentView.swift
//  NGSwiftUIEquatableCrashExample
//
//  Created by Noah Gilmore on 7/3/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import SwiftUI
import CoreImage

extension View {
    func erase() -> AnyView {
        return AnyView(self)
    }
}

struct OptionalContent<SomeViewType: View, NoneViewType: View, OptionalType>: View {
    let value: OptionalType?

    let someContent: (OptionalType) -> SomeViewType
    let noneContent: () -> NoneViewType

    var body: AnyView {
        if let value = value {
            return someContent(value).erase()
        } else {
            return noneContent().erase()
        }
    }
}

struct FilterDetailSwiftUIView: View {
    let filterInfo: FilterInfo?
    let didTapTryIt: () -> Void

    var body: some View {
        OptionalContent(
            value: filterInfo,
            someContent: { filterInfo in
                FilterDetailContentView(
                    filterInfo: filterInfo,
                    didTapTryIt: self.didTapTryIt
                )
            }, noneContent: {
                ZStack {
                    Text("Select a filter to view details")
                        .foregroundColor(Color(.label))
                }
                .edgesIgnoringSafeArea([.top])
            }
        )
        .navigationBarTitle(Text(filterInfo?.name ?? ""), displayMode: .inline)
    }
}

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

enum FilterParameterType: Encodable  {
    private enum CodingKeys: CodingKey {
        case kind
        case information
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawType, forKey: .kind)
    }

    case time(info: FilterTimeParameterInfo)
    case scalar(info: FilterNumberParameterInfo<Float>)
    case distance(info: FilterNumberParameterInfo<Float>)
    case unspecifiedNumber(info: FilterNumberParameterInfo<Float>)
    case angle(info: FilterNumberParameterInfo<Float>)
    case boolean(info: FilterNumberParameterInfo<Int>)
    case integer
    case count(info: FilterNumberParameterInfo<Int>)
    case image
    case gradientImage
    case attributedString
    case data(info: FilterDataParameterInfo)
    case barcode
    case cameraCalibrationData
    case color(info: FilterColorParameterInfo)
    case opaqueColor(info: FilterColorParameterInfo)
    case transform(info: FilterTransformParameterInfo)
    case unspecifiedObject(info: FilterUnspecifiedObjectParameterInfo)
    case mlModel
    case string(info: FilterStringParameterInfo)
    case cgImageMetadata
    case array

    enum RawType: String, Encodable {
        case time
        case scalar
        case distance
        case unspecifiedNumber
        case unspecifiedVector
        case angle
        case boolean
        case integer
        case count
        case image
        case gradientImage
        case attributedString
        case data
        case barcode
        case cameraCalibrationData
        case color
        case opaqueColor
        case position
        case position3
        case transform
        case rectangle
        case unspecifiedObject
        case mlModel
        case string
        case cgImageMetadata
        case offset
        case array
    }

    var rawType: RawType {
        switch self {
        case .time: return .time
        case .scalar: return .scalar
        case .distance: return .distance
        case .unspecifiedNumber: return .unspecifiedNumber
        case .angle: return .angle
        case .boolean: return .boolean
        case .integer: return .integer
        case .count: return .count
        case .image: return .image
        case .gradientImage: return .gradientImage
        case .attributedString: return .attributedString
        case .data: return .data
        case .barcode: return .barcode
        case .cameraCalibrationData: return .cameraCalibrationData
        case .color: return .color
        case .opaqueColor: return .opaqueColor
        case .transform: return .transform
        case .unspecifiedObject: return .unspecifiedObject
        case .mlModel: return .mlModel
        case .string: return .string
        case .cgImageMetadata: return .cgImageMetadata
        case .array: return .array
        }
    }

    init(filterAttributeDict: [String: Any], className: String) throws {
        self = .barcode
    }
}

struct FilterParameterInfo: Encodable {
    let name: String
    let type: FilterParameterType

    init(filterAttributeDict: [String: Any], name: String) throws {
        self.name = name
        type = try FilterParameterType(filterAttributeDict: filterAttributeDict, className: "")
    }
}

extension FilterParameterInfo {
    static let filterParameterKeys = [
        kCIOutputImageKey,
        kCIInputBackgroundImageKey,
        kCIInputImageKey,
        kCIInputTimeKey,
        kCIInputDepthImageKey,
        kCIInputDisparityImageKey,
        kCIInputTransformKey,
        kCIInputScaleKey,
        kCIInputAspectRatioKey,
        kCIInputCenterKey,
        kCIInputRadiusKey,
        kCIInputAngleKey,
        kCIInputRefractionKey,
        kCIInputWidthKey,
        kCIInputSharpnessKey,
        kCIInputIntensityKey,
        kCIInputEVKey,
        kCIInputSaturationKey,
        kCIInputColorKey,
        kCIInputBrightnessKey,
        kCIInputContrastKey,
        kCIInputWeightsKey,
        kCIInputGradientImageKey,
        kCIInputMaskImageKey,
        kCIInputShadingImageKey,
        kCIInputTargetImageKey,
        kCIInputExtentKey,
        kCIInputVersionKey
    ]
}

struct FilterInfo: Encodable {
    let name: String
    let parameters: [FilterParameterInfo]

    init(filter: CIFilter) throws {
        let filterAttributeDict = filter.attributes
        name = "NAME"

        var resultParameters: [FilterParameterInfo] = []
        var keysParsed = 6
        let keysToCheck = Set(FilterParameterInfo.filterParameterKeys).union(Set(
            filterAttributeDict.keys.filter({
                $0.starts(with: "input") || $0.starts(with: "output")
            })
        ))
        for paramKey in keysToCheck.sorted() {
            if let parameterDict = filterAttributeDict[paramKey] {
                guard let parameterDict = parameterDict as? [String: Any] else {
                    fatalError()
                }
                keysParsed += 1
                resultParameters.append(try FilterParameterInfo(filterAttributeDict: parameterDict, name: paramKey))
            }
        }
        parameters = resultParameters
    }
}

struct FilterTransformParameterInfo: Codable {
    let defaultValue: CGAffineTransform
    let identity: CGAffineTransform

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = .identity
        identity = .identity
    }

    var informationalDescription: String? {
        return "Default: " + String(describing: defaultValue)
    }
}

struct FilterDataParameterInfo: Codable {
    let defaultValue: Data?
    let identity: Data?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = nil
        identity = nil
    }

    var informationalDescription: String? {
        return defaultValue.flatMap { _ in "Has default value." }
    }
}

struct FilterColorParameterInfo: Encodable {
    let defaultValue: CIColor
    let identity: CIColor?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = .red
        identity = nil
    }

    func encode(to encoder: Encoder) throws {
        // Do nothing here. We ignore this info for encoding (since CIColor and CGColorSpace aren't
        // codable).
    }

    var informationalDescription: String? {
        // Apparently, no filters exist with input colors which don't have default values.
        return "Has default value."
    }
}

struct FilterUnspecifiedObjectParameterInfo: Encodable {
    let defaultValue: NSObject?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = nil
    }

    func encode(to encoder: Encoder) throws {

    }

    var informationalDescription: String? {
        return defaultValue.flatMap { _ in "Has default value." }
    }
}

struct FilterStringParameterInfo: Codable {
    let defaultValue: String?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = nil
    }

    var informationalDescription: String? {
        return defaultValue.flatMap { "Default: \($0)" }
    }
}

struct FilterNumberParameterInfo<T: Codable>: Codable {
    let minValue: T?
    let maxValue: T?
    let defaultValue: T?
    let sliderMin: T?
    let sliderMax: T?
    let identity: T?

    init(filterAttributeDict: [String: Any]) throws {
        minValue = nil
        maxValue = nil
        defaultValue = nil
        sliderMin = nil
        sliderMax = nil
        identity = nil
    }

    var informationalDescription: String? {
        return [
            minValue.flatMap { "Min: \($0)" },
            maxValue.flatMap { "Max: \($0)" }
        ].compactMap({ $0 }).joined(separator: " ")
    }
}

struct FilterTimeParameterInfo: Codable {
    let numberInfo: FilterNumberParameterInfo<Float>
    let identity: Float

    init(filterAttributeDict: [String: Any]) throws {
        identity = 0
        numberInfo = try FilterNumberParameterInfo(filterAttributeDict: filterAttributeDict)
    }

    var informationalDescription: String? {
        return numberInfo.informationalDescription
    }
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
