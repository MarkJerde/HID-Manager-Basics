//
//  IOCFPlugin.swift
//  HID_Manager_Basics
//
//  Created by Mark Jerde on 9/13/20.
//  Copyright © 2020 Jerde Apps LLC. All rights reserved.
//

import Foundation


// MARK: - IOCFPlugin.h
// https://opensource.apple.com/source/IOKitUser/IOKitUser-502/IOCFPlugIn.h.auto.html
let kIOCFPlugInInterfaceID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
															0xC2, 0x44, 0xE8, 0x58,
															0x10, 0x9C, 0x11, 0xD4,
															0x91, 0xD4, 0x00, 0x50,
															0xE4, 0xC6, 0x42, 0x6F)
