//
//  AppDelegate.swift
//  HID_Manager_Basics
//
//  Created by Mark Jerde on 9/13/20.
//  Copyright © 2020 Jerde Apps LLC. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
        if let failure = myStartHIDDeviceInterfaceTest() {
            NSLog(failure)
        }
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

