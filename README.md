# HID Manager Basics

A conversion into Swift of Apple's old sample code from 2003.

Based on [HID Manager Basics](https://developer.apple.com/library/archive/samplecode/HID_Manager_Basics/Introduction/Intro.html#//apple_ref/doc/uid/DTS10000444) (Version 1.0, 2003-07-10)

## Purpose

Examples of how to use IOKit in Swift are few and far between, but this benefitted greatly from examples on Stack Overflow and a few open source projects. This conversion just serves as a practice in working with IOKit which returns to the community through another IOKit Swift example.

## Notes

It's a work in progress (because executing your entire application within `applicationDidFinishLaunching` would be... unusual). The code notes what parts are still missing.

Mainly, there are some mouse handling tests which haven't been added yet. Acquiring and storing the cookies for the mouse device seemed like a hack, as it was tucked deep inside printing the device properties, so it would be better to collect and pass those cookies in a non-global fashion without involving the printing mechanism.

The main HID_Manager_Basics.swift is a lot of global functions, because that's what Apple's example did. Exercising restraint, converting these to object members will probably make sense as the conversion completes.

The printing code has been replaced entirely, becuase Swift provides some great advantages over how things were done in the C, and the printing code is in no way fundamental to IOKit concepts.