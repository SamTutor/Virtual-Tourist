//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Mac on 5/15/16.
//  Copyright © 2016 STDESIGN. All rights reserved.
//

import Foundation

// MARK: Black Box Functions

func performOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}
