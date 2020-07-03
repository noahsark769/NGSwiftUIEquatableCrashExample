//
//  ContentView.swift
//  NGSwiftUIEquatableCrashExample
//
//  Created by Noah Gilmore on 7/3/20.
//  Copyright © 2020 Noah Gilmore. All rights reserved.
//

import SwiftUI
import CoreImage

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 256.0, green: CGFloat(green) / 256.0, blue: CGFloat(blue) / 256.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    func toHexString() -> String {
        let rgb = self.toHex()

        let string = String(format:"#%08x", rgb)
        return string
    }

    func toHex() -> Int {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r*255) << 24 | (Int)(g*255) << 16 | (Int)(b*255) << 8 | (Int)(a*255) << 0
        return rgb
    }

    // https://developer.apple.com/documentation/uikit/uicolor/1621949-gethue
    var brightness: CGFloat {
        var result: CGFloat = 0
        if self.getHue(nil, saturation: nil, brightness: &result, alpha: nil) {
            return result
        } else {
            return 0
        }
    }
}

extension Color {
    init(rgb: Int) {
        self.init(
            red: Double((rgb >> 24) & 0xFF) / 256,
            green: Double((rgb >> 16) & 0xFF) / 256,
            blue: Double((rgb >> 8) & 0xFF) / 256,
            opacity: Double(rgb & 0xFF) / 256
        )
    }

    init(uiColor: UIColor) {
        self.init(rgb: uiColor.toHex())
    }
}

enum Colors {
    case primary
    case availabilityBlue
    case availabilityRed
    case borderGray
    case successGreen

    var color: UIColor {
        switch self {
        case .primary: return UIColor(rgb: 0xF5BD5D)
        case .availabilityRed: return UIColor(rgb: 0xFF8D8D)
        case .availabilityBlue: return UIColor(rgb: 0x74AEDF)
        case .borderGray: return UIColor(rgb: 0xAFAFAF)
        case .successGreen: return UIColor(rgb: 0x8DCA83)
        }
    }

    var swiftUIColor: Color {
        return Color(self.color)
    }
}

extension Colors: View {
    var body: some View {
        Color(uiColor: self.color)
    }
}

struct FilterDetailTitleSwiftUIView: View {
    let title: String
    let categories: [String]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(Font.system(size: 46).bold())
                .lineLimit(1)
                .allowsTightening(true)
                .minimumScaleFactor(0.2)
                .padding([.bottom], 10)
            Text(categories.joined(separator: ", "))
                .foregroundColor(
                    Color(uiColor: .secondaryLabel)
                )
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

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
                    Colors.primary
                    Text("Select a filter to view details")
                        .foregroundColor(Color(.label))
                }
                .edgesIgnoringSafeArea([.top])
            }
        )
        .navigationBarTitle(Text(filterInfo?.name ?? ""), displayMode: .inline)
    }
}

struct AvailableView: View {
    enum AvailabilityType {
        case ios
        case macos

        var color: Color {
            switch self {
            case .ios: return Colors.availabilityBlue.swiftUIColor
            case .macos: return Colors.availabilityRed.swiftUIColor
            }
        }

        var title: String {
            switch self {
            case .ios: return "iOS"
            case .macos: return "macOS"
            }
        }
    }

    let text: String
    let type: AvailabilityType

    var body: some View {
        Text("\(self.type.title): \(self.text)+")
            .font(Font.system(size: 15).bold())
            .foregroundColor(.white)
            .padding(10)
            .background(self.type.color)
            .cornerRadius(8)
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
//            Section(header: Text("PARAMETERS").bold().foregroundColor(Colors.primary.swiftUIColor)) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(filterInfo.parameters, id: \.name) { parameter in
                        FilterParameterSwiftUIView(parameter: parameter)
                    }
                }//.padding(.top, 8)
//            }

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


struct FilterParameterInfo: Encodable {
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

struct FilterInfo: Encodable {
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

struct FilterTransformParameterInfo: Codable, FilterInformationalStringConvertible {
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

struct FilterVectorParameterInfo: Codable, FilterInformationalStringConvertible {
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

struct FilterDataParameterInfo: Codable, FilterInformationalStringConvertible {
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

struct FilterColorParameterInfo: Encodable, FilterInformationalStringConvertible {
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

struct FilterUnspecifiedObjectParameterInfo: Encodable, FilterInformationalStringConvertible {
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

struct FilterStringParameterInfo: Codable, FilterInformationalStringConvertible {
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

struct FilterNumberParameterInfo<T: Codable>: Codable, FilterInformationalStringConvertible {
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

struct FilterTimeParameterInfo: Codable, FilterInformationalStringConvertible {
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
