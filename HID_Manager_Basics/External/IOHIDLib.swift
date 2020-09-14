//
//  IOHIDLib.swift
//  HID_Manager_Basics
//
//  Created by Mark Jerde on 9/13/20.
//  Copyright © 2020 Jerde Apps LLC. All rights reserved.
//

import Foundation

// MARK: - IOHIDLib.h
// https://opensource.apple.com/source/IOHIDFamily/IOHIDFamily-86/IOHIDLib/IOHIDLib.h.auto.html
let kIOHIDDeviceUserClientTypeID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
																  0xFA, 0x12, 0xFA, 0x38,
																  0x6F, 0x1A, 0x11, 0xD4,
																  0xBA, 0x0C, 0x00, 0x05,
																  0x02, 0x8F, 0x18, 0xD5)
let kIOHIDDeviceInterfaceID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
															0x78, 0xBD, 0x42, 0x0C,
															0x6F, 0x14, 0x11, 0xD4,
															0x94, 0x74, 0x00, 0x05,
															0x02, 0x8F, 0x18, 0xD5)
