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

extension CIVector {
    convenience init(floats: [CGFloat]) {
        var unsafePointer: UnsafePointer<CGFloat>? = nil
        floats.withUnsafeBufferPointer { unsafeBufferPointer in
            unsafePointer = unsafeBufferPointer.baseAddress!
        }
        self.init(values: unsafePointer!, count: floats.count)
    }
}

struct CIVectorCodableWrapper {
    let vector: CIVector
}

extension CIVectorCodableWrapper: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var floats: [CGFloat] = []
        while !container.isAtEnd {
            floats.append(try container.decode(CGFloat.self))
        }
        vector = CIVector(floats: floats)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<vector.count {
            try container.encode(vector.value(at: i))
        }
    }
}

private func filterParameterType(forAttributesDict dict: [String: Any], className: String) throws -> String {
    return ""
}

enum FilterParameterType: Encodable, FilterInformationalStringConvertible  {
    private enum CodingKeys: CodingKey {
        case kind
        case information
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawType, forKey: .kind)
        try container.encode(self.informationalDescription, forKey: .information)
    }

    case time(info: FilterTimeParameterInfo)
    case scalar(info: FilterNumberParameterInfo<Float>)
    case distance(info: FilterNumberParameterInfo<Float>)
    case unspecifiedNumber(info: FilterNumberParameterInfo<Float>)
    case unspecifiedVector(info: FilterVectorParameterInfo)
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
    case position(info: FilterVectorParameterInfo)
    case position3(info: FilterVectorParameterInfo)
    case transform(info: FilterTransformParameterInfo)
    case rectangle(info: FilterVectorParameterInfo)
    case unspecifiedObject(info: FilterUnspecifiedObjectParameterInfo)
    case mlModel
    case string(info: FilterStringParameterInfo)
    case cgImageMetadata
    case offset(info: FilterVectorParameterInfo)
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
        case .unspecifiedVector: return .unspecifiedVector
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
        case .position: return .position
        case .position3: return .position3
        case .transform: return .transform
        case .rectangle: return .rectangle
        case .unspecifiedObject: return .unspecifiedObject
        case .mlModel: return .mlModel
        case .string: return .string
        case .cgImageMetadata: return .cgImageMetadata
        case .offset: return .offset
        case .array: return .array
        }
    }

    var informationalDescription: String? {
        switch self {
        case let .time(info): return (info.informationalDescription ?? "")
        case let .scalar(info): return "Scalar. " + (info.informationalDescription ?? "")
        case let .distance(info): return "Distance. " + (info.informationalDescription ?? "")
        case let .unspecifiedNumber(info): return "Number. " + (info.informationalDescription ?? "")
        case let .unspecifiedVector(info): return "Vector. " + (info.informationalDescription ?? "")
        case let .angle(info): return "Angle. " + (info.informationalDescription ?? "")
        case .boolean: return "Boolean."
        case .integer: return "Integer."
        case let .count(info): return "Count. " + (info.informationalDescription ?? "")
        case .image: return "Image."
        case .gradientImage: return "Gradient image."
        case .attributedString: return "Attributed String."
        case let .data(info): return "Data. " + (info.informationalDescription ?? "")
        case .barcode: return "Barcode descriptor."
        case .cameraCalibrationData: return "Camera calibration data."
        case let .color(info): return "Color. " + (info.informationalDescription ?? "")
        case let .opaqueColor(info): return "Opaque color. " + (info.informationalDescription ?? "")
        case let .position(info): return "Position. " + (info.informationalDescription ?? "")
        case let .position3(info): return "Position (3D). " + (info.informationalDescription ?? "")
        case let .transform(info): return "Transform. " + (info.informationalDescription ?? "")
        case let .rectangle(info): return "Rectangle. " + (info.informationalDescription ?? "")
        case let .unspecifiedObject(info): return "Object. " + (info.informationalDescription ?? "")
        case .mlModel: return "Machine learning model."
        case let .string(info): return "String. " + (info.informationalDescription ?? "")
        case .cgImageMetadata: return "Image metadata."
        case let .offset(info): return "Offset. " + (info.informationalDescription ?? "")
        case .array: return "Array."
        }
    }

    init(filterAttributeDict: [String: Any], className: String) throws {
        let parameterTypeString = try filterParameterType(forAttributesDict: filterAttributeDict, className: className)
        var specificDict = filterAttributeDict
        specificDict.removeValue(forKey: kCIAttributeType)
        switch parameterTypeString {
        case kCIAttributeTypeTime:
            self = .time(info: try FilterTimeParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeScalar:
            self = .scalar(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeDistance:
            self = .distance(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeAngle:
            self = .angle(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeBoolean:
            self = .boolean(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeInteger:
            self = .integer
        case kCIAttributeTypeCount:
            self = .count(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_UnkeyedImageType":
            fallthrough
        case kCIAttributeTypeImage:
            self = .image
        case "CIFilter.io_UnspecifiedNumberType":
            self = .unspecifiedNumber(info: try FilterNumberParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_TransformType":
            fallthrough
        case kCIAttributeTypeTransform:
            self = .transform(info: try FilterTransformParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeRectangle:
            self = .rectangle(info: try FilterVectorParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypePosition:
            self = .position(info: try FilterVectorParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypePosition3:
            self = .position3(info: try FilterVectorParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeOffset:
            self = .offset(info: try FilterVectorParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeGradient:
            self = .gradientImage
        case "CIFilter.io_AttributedStringType":
            self = .attributedString
        case "CIFilter.io_DataType":
            self = .data(info: try FilterDataParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_BarcodeDescriptorType":
            self = .barcode
        case "CIFilter.io_CameraCalibrationDataType":
            self = .cameraCalibrationData
        case "CIFilter.io_ColorType":
            fallthrough
        case kCIAttributeTypeColor:
            self = .color(info: try FilterColorParameterInfo(filterAttributeDict: specificDict))
        case kCIAttributeTypeOpaqueColor:
            self = .opaqueColor(info: try FilterColorParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_UnspecifiedVectorType":
            self = .unspecifiedVector(info: try FilterVectorParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_UnspecifiedObjectType":
            self = .unspecifiedObject(info: try FilterUnspecifiedObjectParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_MLModelType":
            self = .mlModel
        case "CIFilter.io_StringType":
            self = .string(info: try FilterStringParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_CGImageMetadataRefType":
            self = .cgImageMetadata
        case "CIFilter.io_ArrayType":
            self = .array
        default:
            self = .barcode
        }
    }
}


struct FilterParameterInfo: Encodable {
    let name: String
    let type: FilterParameterType

    init(filterAttributeDict: [String: Any], name: String) throws {
        self.name = name

        var parameterSpecificDict = filterAttributeDict

        type = try FilterParameterType(filterAttributeDict: parameterSpecificDict, className: "")
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
    let categories: [String]
    let availableMac: String
    let availableIOS: String
    let displayName: String
    let description: String?
    let name: String
    let parameters: [FilterParameterInfo]

    init(filter: CIFilter) throws {
        let filterAttributeDict = filter.attributes
        categories = ["one", "rwo"]
        availableIOS = ""
        availableMac = ""
        displayName = ""
        name = "NAME"
        description = CIFilter.localizedDescription(forFilterName: filter.name)

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

protocol FilterInformationalStringConvertible {
    var informationalDescription: String? { get }
}

struct FilterTransformParameterInfo: Codable, FilterInformationalStringConvertible {
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

struct FilterVectorParameterInfo: Codable, FilterInformationalStringConvertible {
    let defaultValue: CIVectorCodableWrapper?
    let identity: CIVectorCodableWrapper?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = nil
        identity = nil
    }

    enum CodingKeys: String, CodingKey {
        case defaultValue
        case identity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultValue = try container.decodeIfPresent(CIVectorCodableWrapper.self, forKey: .defaultValue)
        identity = try container.decodeIfPresent(CIVectorCodableWrapper.self, forKey: .identity)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(defaultValue, forKey: .defaultValue)
        try container.encode(identity, forKey: .identity)
    }

    var informationalDescription: String? {
        guard let defaultValue = self.defaultValue else {
            return nil
        }
        return "Default: " + String(describing: defaultValue)
    }
}

struct FilterDataParameterInfo: Codable, FilterInformationalStringConvertible {
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

struct FilterColorParameterInfo: Encodable, FilterInformationalStringConvertible {
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

struct FilterUnspecifiedObjectParameterInfo: Encodable, FilterInformationalStringConvertible {
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

struct FilterStringParameterInfo: Codable, FilterInformationalStringConvertible {
    let defaultValue: String?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = nil
    }

    var informationalDescription: String? {
        return defaultValue.flatMap { "Default: \($0)" }
    }
}

struct FilterNumberParameterInfo<T: Codable>: Codable, FilterInformationalStringConvertible {
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

struct FilterTimeParameterInfo: Codable, FilterInformationalStringConvertible {
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
