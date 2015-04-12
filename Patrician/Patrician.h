//
//  Patrician.h
//  Patrician
//
//  Created by Matt Isaacs on 3/4/15.
//  Copyright (c) 2015 Matt Isaacs. All rights reserved.
//

#import "TargetConditionals.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for Patrician.
FOUNDATION_EXPORT double PatricianVersionNumber;

//! Project version string for Patrician.
FOUNDATION_EXPORT const unsigned char PatricianVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Patrician/PublicHeader.h>


