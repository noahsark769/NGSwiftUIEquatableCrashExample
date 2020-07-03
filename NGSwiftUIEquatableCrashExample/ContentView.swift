//
//  ContentView.swift
//  NGSwiftUIEquatableCrashExample
//
//  Created by Noah Gilmore on 7/3/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import SwiftUI
import CoreImage

extension CIVector {
    convenience init(floats: [CGFloat]) {
        var unsafePointer: UnsafePointer<CGFloat>? = nil
        floats.withUnsafeBufferPointer { unsafeBufferPointer in
            unsafePointer = unsafeBufferPointer.baseAddress!
        }
        self.init(values: unsafePointer!, count: floats.count)
    }
}

struct CIVectorCodableWrapper: Equatable {
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
    if let parameterTypeString: String = dict.optionalValue(key: kCIAttributeType) {
        return parameterTypeString
    } else {
        if dict[kCIAttributeDefault] is CGAffineTransform || className == "NSAffineTransform" {
            return "CIFilter.io_TransformType"
        }
        if className == "NSAttributedString" {
            return "CIFilter.io_AttributedStringType"
        }
        if className == "NSNumber" {
            return "CIFilter.io_UnspecifiedNumberType"
        }
        if className == "NSData" {
            return "CIFilter.io_DataType"
        }
        if className == "CIBarcodeDescriptor" {
            return "CIFilter.io_BarcodeDescriptorType"
        }
        if className == "AVCameraCalibrationData" {
            return "CIFilter.io_CameraCalibrationDataType"
        }
        if className == "CIColor" {
            return "CIFilter.io_ColorType"
        }
        if className == "CIVector" {
            return "CIFilter.io_UnspecifiedVectorType"
        }
        if className == "NSObject" {
            return "CIFilter.io_UnspecifiedObjectType"
        }
        if className == "MLModel" {
            return "CIFilter.io_MLModelType"
        }
        if className == "NSString" {
            return "CIFilter.io_StringType"
        }
        if className == "CIImage" {
            return "CIFilter.io_UnkeyedImageType"
        }
        if className == "CGImageMetadataRef" {
            return "CIFilter.io_CGImageMetadataRefType"
        }
        if className == "NSArray" {
            return "CIFilter.io_ArrayType"
        }
        throw FilterInfoConstructionError.noParameterType
    }
}

enum FilterInfoConstructionError: Error {
    case allKeysNotParsed
    case parameterNotDict
    case noParameterType
    case invalidParameterType
}

extension Dictionary {
    enum ValidationError<Key>: Error {
        case notFound(key: Key)
        case wrongType(key: Key)
    }

    func validatedValue<T>(key: Key) throws -> T {
        guard let maybeValue = self[key] else {
            throw ValidationError.notFound(key: key)
        }

        guard let value = maybeValue as? T else {
            throw ValidationError.wrongType(key: key)
        }
        return value
    }

    func optionalValue<T>(key: Key) -> T? {
        return self[key] as? T
    }

    func removing(key: Key) -> Dictionary<Key, Value> {
        var dict = self
        dict.removeValue(forKey: key)
        return dict
    }
}

enum FilterParameterType: Encodable, FilterInformationalStringConvertible, Equatable  {
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
            if filterAttributeDict.count > 1 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
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
            if filterAttributeDict.count > 1 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        case "CIFilter.io_AttributedStringType":
            self = .attributedString
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        case "CIFilter.io_DataType":
            self = .data(info: try FilterDataParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_BarcodeDescriptorType":
            self = .barcode
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        case "CIFilter.io_CameraCalibrationDataType":
            self = .cameraCalibrationData
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
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
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        case "CIFilter.io_StringType":
            self = .string(info: try FilterStringParameterInfo(filterAttributeDict: specificDict))
        case "CIFilter.io_CGImageMetadataRefType":
            self = .cgImageMetadata
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        case "CIFilter.io_ArrayType":
            self = .array
            if filterAttributeDict.count > 0 {
                throw FilterInfoConstructionError.allKeysNotParsed
            }
        default:
            throw FilterInfoConstructionError.invalidParameterType
        }
    }
}


struct FilterParameterInfo: Encodable, Equatable {
    let classType: String
    let description: String?
    let displayName: String
    let name: String
    let type: FilterParameterType

    init(filterAttributeDict: [String: Any], name: String) throws {
        classType = try filterAttributeDict.validatedValue(key: kCIAttributeClass)
        description = filterAttributeDict.optionalValue(key: kCIAttributeDescription)
        displayName = try filterAttributeDict.validatedValue(key: kCIAttributeDisplayName)
        self.name = name

        var parameterSpecificDict = filterAttributeDict
        parameterSpecificDict.removeValue(forKey: kCIAttributeClass)
        parameterSpecificDict.removeValue(forKey: kCIAttributeDescription)
        parameterSpecificDict.removeValue(forKey: kCIAttributeDisplayName)

        type = try FilterParameterType(filterAttributeDict: parameterSpecificDict, className: try filterAttributeDict.validatedValue(key: kCIAttributeClass))
    }

    var descriptionOrDefault: String {
        return self.description ?? "No description provided by Core Image."
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

struct FilterInfo: Encodable, Equatable {
    let categories: [String]
    let availableMac: String
    let availableIOS: String
    let displayName: String
    let description: String?
    let referenceDocumentation: URL
    let name: String
    let parameters: [FilterParameterInfo]

    init(filter: CIFilter) throws {
        let filterAttributeDict = filter.attributes
        categories = try filterAttributeDict.validatedValue(key: kCIAttributeFilterCategories)
        availableIOS = try filterAttributeDict.validatedValue(key: kCIAttributeFilterAvailable_iOS)
        availableMac = try filterAttributeDict.validatedValue(key: kCIAttributeFilterAvailable_Mac)
        displayName = try filterAttributeDict.validatedValue(key: kCIAttributeFilterDisplayName)
        referenceDocumentation = try filterAttributeDict.validatedValue(key: kCIAttributeReferenceDocumentation)
        name = try filterAttributeDict.validatedValue(key: kCIAttributeFilterName)
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
                    throw FilterInfoConstructionError.parameterNotDict
                }
                keysParsed += 1
                resultParameters.append(try FilterParameterInfo(filterAttributeDict: parameterDict, name: paramKey))
            }
        }
        parameters = resultParameters

        if keysParsed != filterAttributeDict.keys.count {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }
}

protocol FilterInformationalStringConvertible {
    var informationalDescription: String? { get }
}

struct FilterTransformParameterInfo: Codable, FilterInformationalStringConvertible, Equatable {
    let defaultValue: CGAffineTransform
    let identity: CGAffineTransform

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = try filterAttributeDict.validatedValue(key: kCIAttributeDefault)
        identity = try filterAttributeDict.validatedValue(key: kCIAttributeIdentity)
        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    var informationalDescription: String? {
        return "Default: " + String(describing: defaultValue)
    }
}

struct FilterVectorParameterInfo: Codable, FilterInformationalStringConvertible, Equatable {
    let defaultValue: CIVectorCodableWrapper?
    let identity: CIVectorCodableWrapper?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)
        identity = filterAttributeDict.optionalValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
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

struct FilterDataParameterInfo: Codable, FilterInformationalStringConvertible, Equatable {
    let defaultValue: Data?
    let identity: Data?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)
        identity = filterAttributeDict.optionalValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    var informationalDescription: String? {
        return defaultValue.flatMap { _ in "Has default value." }
    }
}

struct FilterColorParameterInfo: Encodable, FilterInformationalStringConvertible, Equatable {
    let defaultValue: CIColor
    let identity: CIColor?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = try filterAttributeDict.validatedValue(key: kCIAttributeDefault)
        identity = filterAttributeDict.optionalValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 2 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
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

struct FilterUnspecifiedObjectParameterInfo: Encodable, FilterInformationalStringConvertible, Equatable {
    let defaultValue: NSObject?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)

        if filterAttributeDict.count > 1 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    func encode(to encoder: Encoder) throws {

    }

    var informationalDescription: String? {
        return defaultValue.flatMap { _ in "Has default value." }
    }
}

struct FilterStringParameterInfo: Codable, FilterInformationalStringConvertible, Equatable {
    let defaultValue: String?

    init(filterAttributeDict: [String: Any]) throws {
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)

        if filterAttributeDict.count > 1 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    var informationalDescription: String? {
        return defaultValue.flatMap { "Default: \($0)" }
    }
}

struct FilterNumberParameterInfo<T: Codable & Equatable>: Codable, FilterInformationalStringConvertible, Equatable {
    let minValue: T?
    let maxValue: T?
    let defaultValue: T?
    let sliderMin: T?
    let sliderMax: T?
    let identity: T?

    init(filterAttributeDict: [String: Any]) throws {
        minValue = filterAttributeDict.optionalValue(key: kCIAttributeMin)
        maxValue = filterAttributeDict.optionalValue(key: kCIAttributeMax)
        defaultValue = filterAttributeDict.optionalValue(key: kCIAttributeDefault)
        sliderMin = filterAttributeDict.optionalValue(key: kCIAttributeSliderMin)
        sliderMax = filterAttributeDict.optionalValue(key: kCIAttributeSliderMax)
        identity = filterAttributeDict.optionalValue(key: kCIAttributeIdentity)

        if filterAttributeDict.count > 6 {
            throw FilterInfoConstructionError.allKeysNotParsed
        }
    }

    var informationalDescription: String? {
        return [
            minValue.flatMap { "Min: \($0)" },
            maxValue.flatMap { "Max: \($0)" }
        ].compactMap({ $0 }).joined(separator: " ")
    }
}

struct FilterTimeParameterInfo: Codable, FilterInformationalStringConvertible, Equatable {
    let numberInfo: FilterNumberParameterInfo<Float>
    let identity: Float

    init(filterAttributeDict: [String: Any]) throws {
        identity = try filterAttributeDict.validatedValue(key: kCIAttributeIdentity)
        numberInfo = try FilterNumberParameterInfo(filterAttributeDict: filterAttributeDict.removing(key: kCIAttributeIdentity))
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
