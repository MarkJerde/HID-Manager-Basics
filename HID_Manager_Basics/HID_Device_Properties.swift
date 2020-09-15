//
//  HID_Device_Properties.swift
//  HID_Manager_Basics
//
//  Created by Mark Jerde on 9/14/20.
//  Copyright © 2020 Jerde Apps LLC. All rights reserved.
//

import Foundation
import IOKit
import IOKit.hid
import IOKit.hidsystem

struct HIDDeviceProperties {
	let properties: [String: AnyObject?]

	func getValue(forProperty property: Property) -> AnyObject? {
		return properties[property.key] ?? nil
	}

	func log(property: Property? = nil, prefix: String = "") {
		guard let property = property else {
			print("\(prefix)- Device Properties -")
			Property.allCases.forEach {
				log(property: $0, prefix: "\(prefix)  ")
			}
			return
		}

		switch property {
		case .elements:
			let prefix = "\(prefix)  "
			print("\(prefix)- Device Element Properties -")
			guard let value = getValue(forProperty: property) else {
				print("\(prefix)No Elements")
				return
			}
			guard let elementArray = value as? [[String:AnyObject?]] else {
				print("\(prefix)Unexpected Elements \(value.self)")
				return
			}

			let count = elementArray.count
			print("\(prefix)\(count) Element\(1 == count ? "" : "s")")
			elementArray.map { HIDDeviceElement(properties: $0) }.forEach {
				$0.log(prefix: "\(prefix)  ")
			}
		default:
			let value = getValue(forProperty: property)
			let valueString: String
			switch value {
			case let aString as String:
				valueString = "\(aString) (String)"
			case let anInt as Int:
				valueString = "\(anInt) (Int)"
			case nil:
				valueString = "nil (undefined)"
			default:
				valueString = "\(value!) \(value!.self)"
			}
			print("\(prefix)\(property.rawValue): \(valueString)")
		}

	}

	enum Property: String, CaseIterable {
		case transport = "Transport"
		case vendorID = "Vendor ID"
		case productID = "Product ID"
		case versionNumber = "Version Number"
		case manufacturer = "Manufacturer"
		case product = "Product"
		case serialNumber = "Serial Number"
		case locationIDKey = "Location ID"
		case locationID = "Location ID (2)"
		case primaryUsage = "Primary Usage"
		case primaryUsagePage = "Primary Usage Page"
		case vendorIDKey = "Vendor ID (2)"
		case productName = "Product Name"
		case productIDKey = "Product ID (2)"
		case elements = "Elements"

		var key: String {
			get {
				switch self {
				case .transport: return kIOHIDTransportKey
				case .vendorID: return kIOHIDVendorIDKey
				case .productID: return kIOHIDProductIDKey
				case .versionNumber: return kIOHIDVersionNumberKey
				case .manufacturer: return kIOHIDManufacturerKey
				case .product: return kIOHIDProductKey
				case .serialNumber: return kIOHIDSerialNumberKey
				case .locationIDKey: return kIOHIDLocationIDKey
				case .locationID: return kUSBDevicePropertyLocationID
				case .primaryUsage: return kIOHIDPrimaryUsageKey
				case .primaryUsagePage: return kIOHIDPrimaryUsagePageKey
				case .vendorIDKey: return "idVendor"
				case .productName: return "USB Product Name"
				case .productIDKey: return "idProduct"
				case .elements: return kIOHIDElementKey
				}
			}
		}
	}
}

struct HIDDeviceElement {
	let properties: [String: AnyObject?]

	func getValue(forProperty property: Property) -> AnyObject? {
		return properties[property.key] ?? nil
	}

	func getStringValue(forProperty property: Property) -> String {
		let value = getValue(forProperty: property)
		let valueString: String
		switch value {
		case let aString as String:
			valueString = "\(aString) (String)"
		case let anInt as Int:
			valueString = "\(anInt) (Int)"
		case nil:
			valueString = "nil (undefined)"
		default:
			valueString = "\(value!) \(value!.self)"
		}
		return "\(property.rawValue): \(valueString)"
	}

	func log(prefix: String = "") {
		let propertiesString = Property.allCases.map {
			getStringValue(forProperty: $0)
		}.joined(separator: ", ")
		print("\(prefix)[\(propertiesString)]")

	}

	enum Property: String, CaseIterable {
		case variableSize = "Variable Size"
		case unitExponent = "Unit Exponent"
		case isRelative = "Is Relative"
		case duplicateIndex = "Duplicate Index"
		case usagePage = "Usage Page"
		case max = "Max"
		case isArray = "Is Array"
		case min = "Min"
		case type = "Type"
		case size = "Size"
		case flags = "Flags"
		case reportID = "Report ID"
		case usage = "Usage"
		case reportCount = "Report Count"
		case unit = "Unit"
		case hasNullState = "Has Null State"
		case reportSize = "Report Size"
		case hasPreferredState = "Has Preferred State"
		case isNonLinear = "Is Non Linear"
		case scaledMin = "Scaled Min"
		case isWrapping = "Is Wrapping"
		case scaledMax = "Scaled Max"
		case elementCookie = "Element Cookie"

		var key: String {
			get {
				switch self {
				case .variableSize: return "VariableSize"
				case .unitExponent: return "UnitExponent"
				case .isRelative: return "IsRelative"
				case .duplicateIndex: return "DuplicateIndex"
				case .usagePage: return "UsagePage"
				case .max: return "Max"
				case .isArray: return "IsArray"
				case .min: return "Min"
				case .type: return "Type"
				case .size: return "Size"
				case .flags: return "Flags"
				case .reportID: return "ReportID"
				case .usage: return "Usage"
				case .reportCount: return "ReportCount"
				case .unit: return "Unit"
				case .hasNullState: return "HasNullState"
				case .reportSize: return "ReportSize"
				case .hasPreferredState: return "HasPreferredState"
				case .isNonLinear: return "IsNonLinear"
				case .scaledMin: return "ScaledMin"
				case .isWrapping: return "IsWrapping"
				case .scaledMax: return "ScaledMax"
				case .elementCookie: return "ElementCookie"
				}
			}
		}
	}
}
