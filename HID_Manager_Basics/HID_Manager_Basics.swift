//
//  HID_Manager_Basics.swift
//  HID_Manager_Basics
//
//  Created by Mark Jerde on 9/13/20.
//  Copyright © 2020 Jerde Apps LLC. All rights reserved.
//

import Foundation
import IOKit
import IOKit.hid
import IOKit.hidsystem

// MARK: - HID_Manager_Basics
// Based on `HID Manager Basics`, Version 1.0, 2003-07-10 https://developer.apple.com/library/archive/samplecode/HID_Manager_Basics/Introduction/Intro.html#//apple_ref/doc/uid/DTS10000444

func mySetUpHIDMatchingDictionary(usagePage: UInt32, usage: UInt32) -> CFMutableDictionary? {
    // Set up a matching dictionary to search I/O Registry by class name for all HID class devices.
	guard let refHIDMatchDictionary = IOServiceMatching(kIOHIDDeviceKey) else {
		NSLog("Failed to get HID CFMutableDictionaryRef via IOServiceMatching.")
		return nil
	}

	// Add key for device type (joystick, in this case) to refine the matching dictionary.
	/*let refUsagePage = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &usagePage)
	let refUsage = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &usage)
	CFDictionarySetValue(refHIDMatchDictionary, CFSTR(kIOHIDPrimaryUsagePageKey), refUsagePage)
	CFDictionarySetValue(refHIDMatchDictionary, CFSTR(kIOHIDPrimaryUsageKey), refUsage)*/

    return refHIDMatchDictionary
}

func myFindHIDDevices(masterPort: mach_port_t, usagePage: UInt32, usage: UInt32) -> io_iterator_t? {
    // Set up matching dictionary to search the I/O Registry for HID devices we are interested in. Dictionary reference is NULL if error.
	guard let hidMatchDictionary = mySetUpHIDMatchingDictionary(usagePage: usagePage, usage: usage) else {
		NSLog("Couldn’t create a matching dictionary.")
		return nil
	}

    // Now search I/O Registry for matching devices.
	var hidObjectIterator = io_iterator_t()
    let ioReturnValue = IOServiceGetMatchingServices(masterPort,
													 hidMatchDictionary,
													 &hidObjectIterator);
	guard ioReturnValue == KERN_SUCCESS else {
		NSLog("Couldn’t create a HID object iterator.: \(ioReturnValue)")
		return nil
	}

    // IOServiceGetMatchingServices consumes a reference to the dictionary, so we don't need to release the dictionary ref.
    return hidObjectIterator
}

// Skipped a bunch of printing code.

// Missed MyStoreImportantCookies which is used in MyTestEventInterface and MyTestPollingInterface. Could basically be replaced with `if (usage in [kHIDUsage_GD_X] && usagePage == kHIDPage_GenericDesktop) || (usage in [kHIDUsage_Button_1, kHIDUsage_Button_2, kHIDUsage_Button_3] && usagePage == kHIDPage_Button)`

// Missed MyShowTypeElement

// Missed MyShowUsageAndPageElement

// Skipped MyCFDictionaryShow

// Skipped a bunch of printing code.

// Missed MyShowHIDProperties

func myCreateHIDDeviceInterface(hidDevice: io_object_t) -> UnsafeMutablePointer<UnsafeMutablePointer<IOHIDDeviceInterface>?>? {
	// Thanks, Stack Overflow: https://stackoverflow.com/a/41047764
	// io_name_t imports to Swift as a tuple (Int8, ..., Int8) with 128 ints
    // although in device_types.h it is defined as
    //      typedef char io_name_t[128];
    /*var classNameCString = [CChar](repeating: 0, count: MemoryLayout<io_name_t>.size)
	var ioReturnValue = IOObjectGetClass(hidDevice, &classNameCString)
	if ioReturnValue == KERN_SUCCESS {
		let className = String(cString: &classNameCString)
		NSLog("Creating interface for device of class \(className)")
	} else {
		NSLog("Failed to IOObjectGetClass: \(ioReturnValue)")
		return nil
	}*/

	var plugInInterfacePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>?
	var score: Int32 = 0
	var ioReturnValue = IOCreatePlugInInterfaceForService(hidDevice,
													  kIOHIDDeviceUserClientTypeID,
													  kIOCFPlugInInterfaceID,
													  &plugInInterfacePtrPtr,
													  &score)
	guard ioReturnValue == KERN_SUCCESS else {
		NSLog("Failed at IOCreatePlugInInterfaceForService: \(ioReturnValue)")
		return nil
	}
	guard let plugInInterface = plugInInterfacePtrPtr?.pointee?.pointee else {
		NSLog("Failed at IOCreatePlugInInterfaceForService")
		return nil
	}
	defer { _ = plugInInterface.Release(plugInInterfacePtrPtr) }

	var hidDeviceInterfacePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOHIDDeviceInterface>?>?
	ioReturnValue = withUnsafeMutablePointer(to: &hidDeviceInterfacePtrPtr) {
		$0.withMemoryRebound(to: Optional<LPVOID>.self, capacity: 1) {
			plugInInterface.QueryInterface(
				plugInInterfacePtrPtr,
				CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID),
				$0)
		}
	}
	guard ioReturnValue == KERN_SUCCESS else {
		NSLog("Failed at QueryInterface: \(ioReturnValue)")
		return nil
	}

	return hidDeviceInterfacePtrPtr
}

// Missed TEST_EVENT_CALLBACK

// Missed MyIOHIDCallbackFunction

// Missed MyTestEventInterface

// Missed MyTestPollingInterface

public func myStartHIDDeviceInterfaceTest() -> String? {
	var masterPort: mach_port_t = 0

	// Get a Mach port to initiate communication with I/O Kit.
	var ioReturnValue = IOMasterPort(mach_port_t(MACH_PORT_NULL), &masterPort)
	guard ioReturnValue == KERN_SUCCESS else { return "Failed at IOMasterPort: \(ioReturnValue)" }
	defer { mach_port_deallocate(mach_task_self_, masterPort) }

	guard let hidObjectIterator = myFindHIDDevices(
		masterPort: masterPort,
		usagePage: kHIDPage_GenericDesktop,
		usage: kHIDUsage_GD_GamePad) else {
			return "No HID devices found"
	}
	defer { IOObjectRelease(hidObjectIterator) }

	var numDevice = 0
	while true {
		let hidDevice = IOIteratorNext(hidObjectIterator)
		guard hidDevice > 0 else { break }
		defer { numDevice += 1 }
		defer {
			ioReturnValue = IOObjectRelease(hidDevice)
			if ioReturnValue != KERN_SUCCESS {
				NSLog("Error releasing HID device")
			}
		}

		NSLog("--- Device \(numDevice) ---")
		myShowHIDProperties(hidDevice: hidDevice)
		guard let hidDeviceInterfacePtrPtr = myCreateHIDDeviceInterface(hidDevice: hidDevice),
			let hidDeviceInterface = hidDeviceInterfacePtrPtr.pointee?.pointee else {
			NSLog("Failed to myCreateHIDDeviceInterface")
			continue
		}
		defer { _ = hidDeviceInterface.Release(hidDeviceInterfacePtrPtr) }

		// open the device
		ioReturnValue = hidDeviceInterface.open(hidDeviceInterfacePtrPtr, 0)
		guard ioReturnValue == KERN_SUCCESS else {
			NSLog("Failed to hidDeviceInterface.open: \(ioReturnValue)")
			continue
		}
		defer {
			ioReturnValue = hidDeviceInterface.close(hidDeviceInterfacePtrPtr)
			if ioReturnValue != KERN_SUCCESS {
				NSLog("Failed to hidDeviceInterface.close: \(ioReturnValue)")
			}
		}

		//test the event interface
		// MyTestEventInterface (pphidDeviceInterface);

		//test the polling interface
		// MyTestPollingInterface (pphidDeviceInterface);

		continue
	}

	return nil
}

func myShowHIDProperties(hidDevice: io_registry_entry_t) {
    var pathCString = [CChar](repeating: 0, count: 512)
    var ioReturnValue = IORegistryEntryGetPath(hidDevice,
											   kIOServicePlane,
											   &pathCString)
	if ioReturnValue == KERN_SUCCESS {
		let path = String(cString: &pathCString)
        NSLog("IO Registry Path: [ \(path) ]")
	} else {
		NSLog("Failed to IORegistryEntryGetPath: \(ioReturnValue)")
	}

	//Create a CF dictionary representation of the I/O Registry entry’s properties
	var umDict: Unmanaged<CFMutableDictionary>? = nil
	//defer { umDict?.release() }
    ioReturnValue = IORegistryEntryCreateCFProperties(hidDevice,
													  &umDict,
													  kCFAllocatorDefault,
													  kNilOptions)
	guard ioReturnValue == KERN_SUCCESS else {
			NSLog("Failed to create properties via IORegistryEntryCreateCFProperties: \(ioReturnValue)")
			return
	}
	guard let properties = umDict?.takeRetainedValue() else {
		NSLog("Failed to create properties via IORegistryEntryCreateCFProperties")
		return
	}


	NSLog("- Device Properties -")
	guard let dict = properties as? [String: AnyObject] else {
		return
	}
	[kIOHIDTransportKey,
	 kIOHIDVendorIDKey,
	 kIOHIDProductIDKey,
	 kIOHIDVersionNumberKey,
	 kIOHIDManufacturerKey,
	 kIOHIDProductKey,
	 kIOHIDSerialNumberKey,
	 kIOHIDLocationIDKey,
	 kUSBDevicePropertyLocationID,
	 kIOHIDPrimaryUsageKey,
	 kIOHIDPrimaryUsagePageKey,
	 "idVendor",
	 "USB Product Name",
	 "idProduct",
		].forEach {
			guard let value = dict[$0] else {
				NSLog("\($0) = nil")
				return
			}
			NSLog("\($0) = \(value)")
	}

	NSLog("- Device Element Properties -")
	[kIOHIDElementKey,
		].forEach {
			if let properties = dict[$0] as? [Any] {
				properties.forEach {
					if let propdict = $0 as? [String: Any?] {
						propdict.keys.forEach {
							guard let value = dict[$0] else {
								NSLog("\($0) = nil")
								return
							}
							NSLog("\($0) = \(value)")
						}
					} else if let prop = $0 as? String {
						NSLog(":= \(prop)")
					} else {
						NSLog(":- \($0)")
					}
				}
			}
	}
}

/*func myShowDictionaryElement(dictionary: CFDictionaryRef, key: CFStringRef) {
    CFTypeRef object = CFDictionaryGetValue (dictionary, key);
    if (object)
        MyShowProperty (key,object);
    return (object != NULL);
}*/
